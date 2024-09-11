

use serde::de::DeserializeOwned;
use serde::Serialize;
use sled_extensions::bincode::Tree;

#[derive(Debug)]
pub enum UpdateError {
  KeyExists,
  SledError(sled_extensions::Error),
}

pub trait UpdateTree<T: Serialize + for<'de> DeserializeOwned + Clone + 'static> {
  fn update(&self, old_key: &[u8], new_key: &[u8], item: T) -> Result<(), UpdateError>;
}

impl<T: Serialize + for<'de> DeserializeOwned + Clone + 'static> UpdateTree<T> for Tree<T> {
  fn update(&self, old_key: &[u8], new_key: &[u8], item: T) -> Result<(), UpdateError> {
    // If keys are the same, just update
    if old_key == new_key {
      match self.insert(new_key, item) {
        Ok(_) => return Ok(()),
        Err(e) => return Err(UpdateError::SledError(e)),
      }
    }

    // If keys are different, perform two steps
    // The `sled::transaction` is not used to avoid the lifetime issues
    match self.get(new_key) {
      Ok(Some(_)) => {
        return Err(UpdateError::KeyExists);
      },
      
      _ => {
    
        match self.remove(old_key) {
          Ok(_) => {
            match self.insert(new_key, item) {
              Ok(_) => return Ok(()),
              Err(e) => return Err(UpdateError::SledError(e)),
            }
          },
          Err(e) => return Err(UpdateError::SledError(e)),
        }
      },
    }
  }
}
