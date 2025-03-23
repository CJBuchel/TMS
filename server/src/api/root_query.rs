use async_graphql::{FieldResult, Object};

use crate::features::{
  Team, TeamAPI, TeamRepository, TournamentConfig, TournamentConfigAPI, TournamentConfigRepository,
};

pub struct RootQuery;
#[Object]
impl RootQuery {
  /// @TODO, add system info for client versioning
  async fn system_info(&self) -> String {
    "VERSION".to_string()
  }

  async fn tournament_config(&self) -> FieldResult<TournamentConfigAPI> {
    let config = TournamentConfig::get().await?;
    Ok(TournamentConfigAPI(config))
  }

  async fn teams(&self) -> FieldResult<Vec<TeamAPI>> {
    let teams = Team::get_all().await?;
    let teams = teams.into_iter().map(|(key, team)| TeamAPI(key, team)).collect();
    Ok(teams)
  }

  async fn team(&self, id: String) -> FieldResult<TeamAPI> {
    let team = Team::get(&id).await?;
    Ok(TeamAPI(id, team))
  }
}
