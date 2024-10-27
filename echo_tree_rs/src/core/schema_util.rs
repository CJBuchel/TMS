use serde_json::Value;

use super::EchoTreeServer;
use super::SchemaUtil;

#[async_trait::async_trait]
impl SchemaUtil for EchoTreeServer {
  async fn add_tree_schema(&self, tree_name: String, schema: String) {
    self.database.write().await.add_tree(tree_name, schema).await;
  }

  async fn get_tree_schema(&self, tree_name: String) -> String {
    self.database.read().await.get_hierarchy().await.get_tree_schema(tree_name)
  }

  async fn validate_data_scheme(&self, tree_name: String, data: String) -> bool {
    let read_db = self.database.read().await;
    let schema = read_db.get_hierarchy().await.get_tree_schema(tree_name);

    let schema: Value = serde_json::from_str(&schema).unwrap_or_default();
    let data: Value = serde_json::from_str(&data).unwrap_or_default();

    jsonschema::is_valid(&schema, &data)
  }
}