use std::collections::{HashMap, HashSet};

use anyhow::Result;

use crate::{ChangeOperation, TableBroker};

use super::record::Record;

//
// Table in the database, using two sled trees for data and secondary indexes
// Table stores handles for sled not data, so it's fine to clone
//
#[derive(Debug, Clone)]
pub struct Table {
  data_tree: sled::Tree,
  index_tree: sled::Tree,
}

impl Table {
  /// Generate a new unique key
  fn __generate_key() -> String {
    uuid::Uuid::now_v7().to_string()
  }

  /// Convert bytes into a HashSet of indexes
  fn __index_from_bytes(data: &Vec<u8>) -> HashSet<String> {
    if data.is_empty() {
      return HashSet::new();
    } else {
      match postcard::from_bytes(data) {
        Ok(index) => index,
        Err(_) => HashSet::new(),
      }
    }
  }

  /// Convert a HashSet of indexes into bytes
  fn __index_to_bytes(index: &HashSet<String>) -> Vec<u8> {
    match postcard::to_allocvec(index) {
      Ok(bytes) => bytes,
      Err(_) => Vec::new(),
    }
  }

  /// Remove indexes from the secondary index tree
  /// Only removes the indexes for the specified record, records that share the same index will not be affected
  fn __remove_indexes<R: Record>(&self, batch_update: &mut sled::Batch, record_id: &String, record: &R) -> Result<()> {
    let indexes = record.secondary_indexes();

    for index in indexes {
      let values = self.index_tree.get(index.clone())?.unwrap_or_default();
      let mut value_set = Self::__index_from_bytes(&values.to_vec());
      value_set.remove(record_id);
      if value_set.is_empty() {
        batch_update.remove(index.as_str());
      } else {
        let bytes = Self::__index_to_bytes(&value_set);
        batch_update.insert(index.as_str(), bytes);
      }
    }

    Ok(())
  }

  /// Insert the secondary indexes for a record (adds the record_id as the data for the index)
  fn __insert_indexes<R: Record>(&self, batch_update: &mut sled::Batch, record_id: &String, record: &R) -> Result<()> {
    let indexes = record.secondary_indexes();
    for index in indexes {
      // Get the current set of record ids for this index (assuming it exists)
      let values = self.index_tree.get(index.clone())?.unwrap_or_default();
      let mut value_set = Self::__index_from_bytes(&values.to_vec());
      // Insert the record id into the set
      value_set.insert(record_id.clone());
      // Update the index tree with the new set
      let bytes = Self::__index_to_bytes(&value_set);
      batch_update.insert(index.as_str(), bytes);
    }

    Ok(())
  }

  /// Insert a record into the table
  fn __insert_record<R: Record>(&self, batch_update: &mut sled::Batch, key: &String, record: &R) -> Result<String> {
    let record_id = key.clone();
    let record_data = record.to_bytes();
    batch_update.insert(key.as_str(), record_data);
    Ok(record_id)
  }

  /// Remove a record from the table
  fn __remove_record(&self, batch_update: &mut sled::Batch, key: &String) -> Result<()> {
    batch_update.remove(key.as_str());
    Ok(())
  }

  /// Get a HashSet of record_id's from the index tree using a secondary index to search
  /// Returns an empty HashSet if the index does not exist
  /// Can return multiple record_id's if multiple records share the same index
  fn __get_record_ids(&self, index: &str) -> Result<HashSet<String>> {
    let values = self.index_tree.get(index)?.unwrap_or_default();
    let value_set = Self::__index_from_bytes(&values.to_vec());
    Ok(value_set)
  }

  //
  // - Public Functions -
  //

  /// Open a table for a given record
  pub fn open<R: Record + 'static>(db: &sled::Db) -> Result<Self> {
    let table_name = R::table_name();
    let data_tree = db.open_tree(format!("{}_data", table_name))?;
    let index_tree = db.open_tree(format!("{}_index", table_name))?;

    Ok(Self { data_tree, index_tree })
  }

  /// Clear the table of all records and indexes
  pub fn clear(&self) -> Result<()> {
    self.data_tree.clear()?;
    self.index_tree.clear()?;
    Ok(())
  }

  /// Insert a record into the table
  /// Returns the key of the inserted record
  pub fn insert<R: Record + 'static>(&self, key: Option<&String>, record: &R) -> Result<String> {
    let mut data_batch_update = sled::Batch::default();
    let mut index_batch_update = sled::Batch::default();

    // insert data record
    let record_id = match key {
      Some(key) => self.__insert_record(&mut data_batch_update, &key, record)?,
      None => self.__insert_record(&mut data_batch_update, &Self::__generate_key(), record)?,
    };

    // insert secondary indexes for the record
    self.__insert_indexes(&mut index_batch_update, &record_id, record)?;

    // apply the batch updates
    self.data_tree.apply_batch(data_batch_update)?;
    self.index_tree.apply_batch(index_batch_update)?;

    // publish changes to channel subscribes
    TableBroker::<R>::publish(ChangeOperation::Insert(record_id.clone(), record.clone()));

    Ok(record_id)
  }

  /// Batch insert records into the table
  /// If an error occurs during the batch insert, the entire batch will be rolled back
  pub fn batch_insert<R: Record + 'static>(&self, records: HashMap<&String, &R>) -> Result<()> {
    let mut data_batch_update = sled::Batch::default();
    let mut index_batch_update = sled::Batch::default();

    for (key, record) in records.clone() {
      self.__insert_record(&mut data_batch_update, &key, record)?;
      self.__insert_indexes(&mut index_batch_update, &key, record)?;
    }

    // apply batch updates
    self.data_tree.apply_batch(data_batch_update)?;
    self.index_tree.apply_batch(index_batch_update)?;

    // publish changes to channel subscribes
    for (key, record) in records {
      TableBroker::<R>::publish(ChangeOperation::Insert(key.clone(), record.clone()));
    }

    Ok(())
  }

  /// Remove a record from the table
  pub fn remove<R: Record + 'static>(&self, key: &String) -> Result<()> {
    let mut data_batch_update = sled::Batch::default();
    let mut index_batch_update = sled::Batch::default();

    // get copy of record
    let record_bytes = self.data_tree.get(key)?.unwrap_or_default().to_vec();
    let record = R::from_bytes(&record_bytes);

    // remove data record
    self.__remove_record(&mut data_batch_update, key)?;

    // remove record indexes
    self.__remove_indexes(&mut index_batch_update, key, &record)?;

    // apply batch updates
    self.data_tree.apply_batch(data_batch_update)?;
    self.index_tree.apply_batch(index_batch_update)?;

    // publish changes to channel subscribes
    TableBroker::<R>::publish(ChangeOperation::Remove(key.clone()));

    Ok(())
  }

  /// Batch remove records from the table
  pub fn batch_remove<R: Record + 'static>(&self, keys: HashSet<&String>) -> Result<()> {
    let mut data_batch_update = sled::Batch::default();
    let mut index_batch_update = sled::Batch::default();

    for key in keys.clone() {
      // get copy of record
      let record_bytes = self.data_tree.get(key.clone())?.unwrap_or_default().to_vec();
      let record = R::from_bytes(&record_bytes);

      // remove data record
      self.__remove_record(&mut data_batch_update, &key)?;
      self.__remove_indexes(&mut index_batch_update, &key, &record)?;
    }

    // apply batch updates
    self.data_tree.apply_batch(data_batch_update)?;
    self.index_tree.apply_batch(index_batch_update)?;

    // publish changes to channel subscribes
    for key in keys {
      TableBroker::<R>::publish(ChangeOperation::Remove(key.clone()));
    }

    Ok(())
  }

  /// Get record by key
  pub fn get<R: Record>(&self, key: &String) -> Result<Option<R>> {
    match self.data_tree.get(key)? {
      Some(record_bytes) => {
        let record = R::from_bytes(&record_bytes);
        Ok(Some(record))
      }
      None => Ok(None),
    }
  }

  /// Get records by secondary index
  /// Returns a HashMap of record_id's to records that are associated with the index
  pub fn get_by_index<R: Record>(&self, index_key: &String) -> Result<HashMap<String, R>> {
    let record_ids = self.__get_record_ids(index_key)?;
    let mut records = HashMap::new();
    for record_id in record_ids {
      match self.get::<R>(&record_id)? {
        Some(record) => {
          records.insert(record_id, record);
        }
        None => {
          log::warn!("Record {} not found in table, removing from index", record_id);
        }
      }
    }

    Ok(records)
  }

  /// Get all records in the table
  pub fn get_all<R: Record>(&self) -> Result<HashMap<String, R>> {
    let mut records = HashMap::new();
    for record in self.data_tree.iter() {
      let (key, value) = record?;
      let record = R::from_bytes(&value);
      let key_str = String::from_utf8(key.to_vec())?;
      records.insert(key_str, record);
    }

    Ok(records)
  }

  /// Get an iterator for the table
  pub fn iter(&self) -> sled::Iter {
    self.data_tree.iter()
  }
}
