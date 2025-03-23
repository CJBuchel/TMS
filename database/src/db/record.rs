use anyhow::Result;
use serde::{Serialize, de::DeserializeOwned};

pub trait Record: Default + Clone + Sync + Send + Serialize + DeserializeOwned {
  //
  // Convert the record to bytes
  //
  fn to_bytes(&self) -> Result<Vec<u8>> {
    let bytes = match postcard::to_allocvec(self) {
      Ok(bytes) => bytes,
      Err(err) => {
        log::error!("Failed to serialize record: {:?}", err);
        return Err(anyhow::anyhow!("Failed to serialize record"));
      }
    };
    Ok(bytes)
  }

  //
  // Convert bytes to a record
  //
  fn from_bytes(bytes: &[u8]) -> Result<Self> {
    let record = match postcard::from_bytes(bytes) {
      Ok(record) => record,
      Err(err) => {
        log::error!("Failed to deserialize record: {:?}", err);
        return Err(anyhow::anyhow!("Failed to deserialize record"));
      }
    };
    Ok(record)
  }

  //
  // Get the secondary searchable indexes for this record.
  // Speeds up searching for records based on a secondary index that is not the primary key.
  // I.e, author_name, age, etc...
  //
  fn secondary_indexes(&self) -> Vec<String> {
    vec![]
  }

  //
  // - REQUIRED - The name of the table in the database
  //
  fn table_name() -> &'static str;
}
