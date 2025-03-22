#[derive(Clone)]
pub enum ChangeOperation<T> {
  Insert(String, T), // id, record
  Remove(String),    // id
}
