use async_graphql::Object;

use super::model::Team;

pub struct TeamAPI(pub String, pub Team);

#[Object]
impl TeamAPI {
  async fn id(&self) -> &str {
    &self.0
  }

  async fn team_number(&self) -> &str {
    &self.1.team_number
  }

  async fn name(&self) -> &str {
    &self.1.name
  }

  async fn affiliation(&self) -> &str {
    &self.1.affiliation
  }
}
