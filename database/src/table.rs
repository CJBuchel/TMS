use std::collections::HashMap;

use anyhow::Result;
use prost::Message;

pub struct DataInsert<T: Message + Default> {
  pub id: Option<String>,
  pub value: T,
  pub search_indexes: Vec<String>,
}

const DATA_PREFIX: &str = "data"; // data store
const SEARCH_INDEX_PREFIX: &str = "sid"; // search index

// Representation in db e.g
// table_name:data:{record_key} -> {protobuf bytes}
// table_name:sid:{search_index}:{record_key} -> {record_key}

pub struct Table {
  db: sled::Db,
  name: String,
}

impl Table {
  //
  // -- Private Function --
  //
  fn __generate_uuid() -> String {
    // generate unique key for the record
    uuid::Uuid::now_v7().to_string()
  }

  fn __insert_search_indexes(&self, batch: &mut sled::Batch, id: &str, search_indexes: Vec<String>) {
    for sid in search_indexes {
      let full_key = format!("{}:{}:{}:{}", self.name, SEARCH_INDEX_PREFIX, sid, id);
      batch.insert(full_key.as_bytes(), id.as_bytes());
    }
  }

  fn __remove_search_indexes(&self, batch: &mut sled::Batch, id: &str) -> Result<()> {
    // Scan format type {name}:sid:*:{id}
    let prefix = format!("{}:{}", self.name, SEARCH_INDEX_PREFIX);
    let suffix = format!(":{}", id);

    for item in self.db.scan_prefix(prefix.as_bytes()) {
      let (key, _) = match item {
        Ok(item) => item,
        Err(e) => {
          log::error!("Failed to scan keys for deletion: {}", e);
          return Err(anyhow::anyhow!(e));
        }
      };

      // Key as string
      let key_str = match String::from_utf8(key.to_vec()) {
        Ok(key_str) => key_str,
        Err(e) => {
          log::error!("Failed to convert key to string: {}", e);
          return Err(anyhow::anyhow!(e));
        }
      };

      // Remove matching key
      if key_str.ends_with(&suffix) {
        batch.remove(key);
      }
    }
    Ok(())
  }

  fn __insert_record<T: Message + Default>(&self, batch: &mut sled::Batch, id: &str, record: &T) {
    // Encode data into protobuf bytes
    let data = Message::encode_to_vec(record);
    // Insert data
    let full_key = format!("{}:{}:{}", self.name, DATA_PREFIX, id);
    batch.insert(full_key.as_bytes(), data);
  }

  fn __remove_record(&self, batch: &mut sled::Batch, id: &str) {
    let full_key = format!("{}:{}:{}", self.name, DATA_PREFIX, id);
    batch.remove(full_key.as_bytes());
  }

  fn __get_record<T: Message + Default>(&self, id: &str) -> Result<Option<T>> {
    let full_key = format!("{}:{}:{}", self.name, DATA_PREFIX, id);
    let bytes: Vec<u8> = match self.db.get(full_key) {
      Ok(v) => match v {
        Some(data) => data.to_vec(),
        None => return Ok(None),
      },
      Err(e) => {
        log::error!("Failed to get redis from db: {}", e);
        return Err(anyhow::anyhow!(e));
      }
    };

    if bytes.is_empty() {
      return Ok(None);
    }

    let record: T = match Message::decode(bytes.as_slice()) {
      Ok(rec) => rec,
      Err(e) => {
        log::error!("Failed to decode record from db: {}", e);
        return Err(anyhow::anyhow!(e));
      }
    };

    Ok(Some(record))
  }

  fn __get_records<T: Message + Default>(&self, ids: Vec<String>) -> Result<HashMap<String, T>> {
    let mut records: HashMap<String, T> = HashMap::new();

    // Get all values (we sadly don't have a proper get_all)
    for id in ids {
      let full_key = format!("{}:{}:{}", self.name, DATA_PREFIX, id);

      if let Some(bytes) = self.db.get(full_key.as_bytes())? {
        let record: T = Message::decode(bytes.as_ref())?;
        records.insert(id, record);
      }
    }

    Ok(records)
  }

  fn __get_record_ids_multi_sid(&self, search_indexes: Vec<String>) -> Vec<String> {
    let mut all_ids: Vec<String> = Vec::new();

    for sid in search_indexes {
      // Scan format type {name}:sid:{search_index}:*
      let prefix = format!("{}:{}:{}", self.name, SEARCH_INDEX_PREFIX, sid);

      // Scan for matching sid keys
      let ids: Vec<String> = self
        .db
        .scan_prefix(prefix.as_bytes())
        .filter_map(Result::ok)
        .map(|(_, key)| String::from_utf8(key.to_vec()).unwrap_or_default())
        .collect();

      all_ids.extend(ids);
    }

    all_ids
  }

  //
  // -- Public Functions --
  //
  pub fn get_table(name: &str, db: sled::Db) -> Self {
    Self { name: name.to_string(), db }
  }

  /// Insert record into the table (returns id of the record)
  pub fn insert<T: Message + Default>(&self, data: DataInsert<T>) -> Result<String> {
    let id = match data.id {
      Some(uuid) => uuid,
      None => Self::__generate_uuid(),
    };

    let mut batch_update = sled::Batch::default();

    self.__insert_search_indexes(&mut batch_update, &id, data.search_indexes);
    self.__insert_record(&mut batch_update, &id, &data.value);

    match self.db.apply_batch(batch_update) {
      Ok(()) => (),
      Err(e) => {
        log::error!("Failed to insert record: {}", e);
        return Err(anyhow::anyhow!(e));
      }
    }

    Ok(id)
  }

  /// Batch insert records (returns list of ids)
  pub fn batch_insert<T: Message + Default>(&self, data: Vec<DataInsert<T>>) -> Result<Vec<String>> {
    let mut batch_update = sled::Batch::default();

    let mut record_ids: Vec<String> = Vec::new();

    for data_insert in data {
      let id = match data_insert.id {
        Some(uuid) => uuid,
        None => Self::__generate_uuid(),
      };

      self.__insert_search_indexes(&mut batch_update, &id, data_insert.search_indexes);
      self.__insert_record(&mut batch_update, &id, &data_insert.value);

      record_ids.push(id);
    }

    match self.db.apply_batch(batch_update) {
      Ok(()) => (),
      Err(e) => {
        log::error!("Failed to batch insert records: {}", e);
        return Err(anyhow::anyhow!(e));
      }
    }

    Ok(record_ids)
  }

  /// Remove record
  pub fn remove(&self, id: &str) -> Result<()> {
    let mut batch_update = sled::Batch::default();

    // Remove indexes
    self.__remove_search_indexes(&mut batch_update, id)?;

    // Remove record
    self.__remove_record(&mut batch_update, id);

    match self.db.apply_batch(batch_update) {
      Ok(()) => (),
      Err(e) => {
        log::error!("Failed to remove record: {}", e);
        return Err(anyhow::anyhow!(e));
      }
    }

    Ok(())
  }

  /// Batch remove records
  pub fn batch_remove(&self, ids: Vec<String>) -> Result<()> {
    let mut batch_update = sled::Batch::default();

    for id in ids {
      self.__remove_search_indexes(&mut batch_update, &id)?;
      self.__remove_record(&mut batch_update, &id);
    }

    match self.db.apply_batch(batch_update) {
      Ok(()) => (),
      Err(e) => {
        log::error!("Failed to batch remove records: {}", e);
        return Err(anyhow::anyhow!(e));
      }
    }

    Ok(())
  }

  /// Get single record by id
  pub fn get<T: Message + Default>(&self, id: &str) -> Result<Option<T>> {
    let record = match self.__get_record::<T>(id) {
      Ok(r) => r,
      Err(e) => {
        log::error!("Failed to get record: {}", e);
        return Err(anyhow::anyhow!(e));
      }
    };

    Ok(record)
  }

  /// Get multiple records by ids
  pub fn batch_get<T: Message + Default>(&self, ids: Vec<String>) -> Result<HashMap<String, T>> {
    let mut records: HashMap<String, T> = HashMap::new();

    for id in ids {
      let record = match self.__get_record::<T>(&id) {
        Ok(r) => r,
        Err(e) => {
          log::error!("Failed to get record: {}", e);
          return Err(anyhow::anyhow!(e));
        }
      };

      if let Some(record) = record {
        records.insert(id, record);
      }
    }

    Ok(records)
  }

  /// Get all records
  pub fn get_all<T: Message + Default>(&self) -> Result<HashMap<String, T>> {
    let prefix = format!("{}:{}:", self.name, DATA_PREFIX);

    let mut records: HashMap<String, T> = HashMap::new();

    for item in self.db.scan_prefix(prefix.as_bytes()) {
      let (key, value) = item?;
      let key_str = String::from_utf8(key.to_vec())?;
      let id = key_str.strip_prefix(&prefix).unwrap_or(&key_str).to_string();
      let record: T = Message::decode(value.to_vec().as_slice())?;
      records.insert(id, record);
    }

    Ok(records)
  }

  /// Get record ids by searchable fields
  pub fn get_by_search_indexes<T: Message + Default>(&self, search_indexes: Vec<String>) -> Result<HashMap<String, T>> {
    let record_ids = self.__get_record_ids_multi_sid(search_indexes);

    let records: HashMap<String, T> = match self.__get_records::<T>(record_ids) {
      Ok(r) => r,
      Err(e) => {
        log::error!("Failed to get records: {}", e);
        return Err(anyhow::anyhow!(e));
      }
    };

    Ok(records)
  }

  /// Scan all records in the table as an iterator (memory efficient)
  /// Returns an iterator of (id, record) tuples
  pub fn scan<T: Message + Default>(&self) -> impl Iterator<Item = Result<(String, T)>> + '_ {
    let prefix = format!("{}:{}:", self.name, DATA_PREFIX);
    let table_name = self.name.clone();

    self.db.scan_prefix(prefix.as_bytes()).map(move |item| {
      let (key, value) = item.map_err(|e| {
        log::error!("Failed to scan key: {}", e);
        anyhow::anyhow!(e)
      })?;

      // Extract ID from key like "teams:data:uuid"
      let key_str = String::from_utf8(key.to_vec()).map_err(|e| {
        log::error!("Failed to convert key to string: {}", e);
        anyhow::anyhow!(e)
      })?;

      let id = key_str.strip_prefix(&format!("{}:{}:", table_name, DATA_PREFIX)).unwrap_or_default().to_string();

      let record: T = Message::decode(value.as_ref()).map_err(|e| {
        log::error!("Failed to decode record from db: {}", e);
        anyhow::anyhow!(e)
      })?;

      Ok((id, record))
    })
  }

  /// Clear all records from the table (deletes both data and search indexes)
  pub fn clear(&self) -> Result<()> {
    let mut batch_update = sled::Batch::default();

    // Scan for all keys with this table's prefix (format: {table_name}:*)
    let prefix = format!("{}:", self.name);

    for item in self.db.scan_prefix(prefix.as_bytes()) {
      let (key, _) = match item {
        Ok(item) => item,
        Err(e) => {
          log::error!("Failed to scan keys for clearing table: {}", e);
          return Err(anyhow::anyhow!(e));
        }
      };

      batch_update.remove(key);
    }

    match self.db.apply_batch(batch_update) {
      Ok(()) => (),
      Err(e) => {
        log::error!("Failed to clear table: {}", e);
        return Err(anyhow::anyhow!(e));
      }
    }

    Ok(())
  }
}
