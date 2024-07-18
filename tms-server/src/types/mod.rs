pub type AtomicRefBool = std::sync::Arc<std::sync::atomic::AtomicBool>;
pub type AtomicRefStrVec = std::sync::Arc<tokio::sync::RwLock<Vec<String>>>;