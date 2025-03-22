use anyhow::Result;

#[derive(serde::Serialize, serde::Deserialize)]
pub struct Collection {
  collection_type: Vec<u8>,
  collection_name: Vec<u8>,
  collection_iter: Vec<Vec<Vec<u8>>>, // collected iterator data
}

#[derive(serde::Serialize, serde::Deserialize)]
pub struct DatabaseCollection {
  data: Vec<Collection>,
}

impl Default for DatabaseCollection {
  fn default() -> Self {
    DatabaseCollection { data: Vec::new() }
  }
}

impl DatabaseCollection {
  pub fn new(data: Vec<(Vec<u8>, Vec<u8>, impl Iterator<Item = Vec<Vec<u8>>> + Send)>) -> Self {
    let serialized_data: Vec<Collection> = data
      .into_iter()
      .map(|(collection_type, collection_name, collection_iter)| Collection {
        collection_type,
        collection_name,
        collection_iter: collection_iter.collect(),
      })
      .collect();

    DatabaseCollection { data: serialized_data }
  }

  pub fn from_bytes(serialized_data: Vec<u8>) -> Result<Self> {
    let db_collection = postcard::from_bytes(&serialized_data)?;
    Ok(db_collection)
  }

  pub fn get(&self) -> Vec<(Vec<u8>, Vec<u8>, impl Iterator<Item = Vec<Vec<u8>>> + Send)> {
    self
      .data
      .iter()
      .map(|sd| {
        let collection_type = sd.collection_type.clone();
        let collection_name = sd.collection_name.clone();
        let collection_iter = sd.collection_iter.clone().into_iter();
        (collection_type, collection_name, collection_iter)
      })
      .collect()
  }

  pub fn to_bytes(&self) -> Result<Vec<u8>> {
    let bytes = postcard::to_allocvec(self)?;
    Ok(bytes)
  }
}
