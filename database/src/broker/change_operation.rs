#[derive(Clone)]
pub struct ChangeOperation<T>(pub String, pub Option<T>); // id, record
