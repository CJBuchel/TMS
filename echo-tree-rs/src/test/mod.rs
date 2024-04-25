
use lazy_static::lazy_static;

use crate::core::{EchoTreeServer, EchoTreeServerConfig, SchemaUtil, TreeManager};

lazy_static! {
  static ref DB_LOCK: std::sync::Mutex<()> = std::sync::Mutex::new(());
}

#[tokio::test]
async fn test_backup() {
  let _guard = DB_LOCK.lock().expect("Failed to lock db");
  let config = EchoTreeServerConfig::default();
  let server = EchoTreeServer::new(config.clone());
  #[derive(serde::Deserialize, serde::Serialize, schemars::JsonSchema)]
  struct Person {
    pub name: String,
    pub age: u8,
  }

  let schema = schemars::schema_for!(Person);
  let schema = serde_json::to_string(&schema).expect("Failed to serialize schema");

  server.add_tree_schema(":people".to_string(), schema).await;
  let person = Person {
    name: "John".to_string(),
    age: 25,
  };

  // insert and backup
  let json = serde_json::to_string(&person).expect("Failed to serialize person");
  server.insert_entry(":people".to_string(), "test".to_string(), json.clone()).await;
  server.backup_db("backups/backup.zip").await.expect("Failed to backup db");
  assert!(std::path::Path::new("backups/backup.zip").exists());
  
  
  // restore and check
  server.restore_db("backups/backup.zip").await.expect("Failed to restore db");
  let entry = server.get_entry(":people".to_string(), "test".to_string()).await;  
  assert_eq!(entry, Some(json));
  let entry: Person = serde_json::from_str(&entry.unwrap()).expect("Failed to deserialize person");
  assert_eq!(entry.name, "John".to_string());
}

