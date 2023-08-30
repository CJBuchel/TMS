use serde::{Serialize, Deserialize};
use sled_extensions::{bincode, Encoding, Db, Result as SledResult};

#[derive(Clone)]
pub struct Item<T: 'static>
where
  T: Serialize + for<'de> Deserialize<'de> + Clone,
{
  db: Db,
  key: Vec<u8>,
  phantom: std::marker::PhantomData<T>,
}

impl<T> Item<T>
where
  T: Serialize + for<'de> Deserialize<'de> + Clone,
{
  pub fn new(db: Db, key: &'static str) -> Self {
    Self {
      db,
      key: key.as_bytes().to_vec(),
      phantom: std::marker::PhantomData,
    }
  }

  pub fn get(&self) -> SledResult<Option<T>> {
    match self.db.get(&self.key) {
      Ok(Some(serialized)) => Ok(Some(bincode::BincodeEncoding::decode(&serialized).expect("Failed to deserialize"))),
      Ok(None) => Ok(None),
      Err(e) => Err(sled_extensions::Error::Sled(e)),
    }
  }

  pub fn set(&self, item: T) -> SledResult<()> {
    let serialized = bincode::BincodeEncoding::encode(&item).expect("Failed to serialize");
    
    match self.db.insert(&self.key, serialized) {
      Ok(_) => Ok(()),
      Err(e) => Err(sled_extensions::Error::Sled(e)),
    }
  }

  pub fn delete(&self) {
    self.db.remove(self.key.clone()).unwrap();
  }
}