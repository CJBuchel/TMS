use async_graphql::{OutputType, SimpleObject};

#[derive(SimpleObject)]
pub struct RecordChangedAPI<T: OutputType> {
  id: String,
  record: Option<T>,
}

impl<T: OutputType> RecordChangedAPI<T> {
  pub fn new(id: String, record: Option<T>) -> Self {
    Self { id, record }
  }
}
