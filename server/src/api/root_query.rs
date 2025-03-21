use async_graphql::Object;

pub struct RootQuery;
#[Object]
impl RootQuery {
  async fn system_info(&self) -> String {
    "".to_string()
  }
}
