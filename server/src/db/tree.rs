use serde::de::DeserializeOwned;
use serde::Serialize;
use sled_extensions::bincode::Tree;
use sled_extensions::Result as SledResult;

pub trait UpdateTree<T: Serialize + for<'de> DeserializeOwned + Clone + 'static> {
  fn update(&self, old_key: &[u8], new_key: &[u8], item: T) -> SledResult<()>;
}

impl<T: Serialize + for<'de> DeserializeOwned + Clone + 'static> UpdateTree<T> for Tree<T> {
  fn update(&self, old_key: &[u8], new_key: &[u8], item: T) -> SledResult<()> {
    // If keys are the same, just update
    if old_key == new_key {
      self.insert(new_key, item)?;
      return Ok(());
    }

    // If keys are different, perform two steps
    // The `sled::transaction` is not used to avoid the lifetime issues
    self.remove(old_key)?;
    self.insert(new_key, item)?;

    Ok(())
  }
}
