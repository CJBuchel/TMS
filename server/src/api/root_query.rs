use async_graphql::{FieldResult, Object};

use crate::features::{Team, TeamAPI, TeamRepository};

pub struct RootQuery;
#[Object]
impl RootQuery {
  /// @TODO, add system info for client versioning
  async fn system_info(&self) -> String {
    "VERSION".to_string()
  }

  async fn teams(&self) -> FieldResult<Vec<TeamAPI>> {
    let teams = Team::get_all().await?;
    let teams = teams.into_iter().map(|(key, team)| TeamAPI(key, team)).collect();
    Ok(teams)
  }
}
