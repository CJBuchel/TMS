use async_graphql::{FieldResult, Object};

use super::{model::Team, TeamRepository};

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

pub struct TeamChangedAPI(pub String);
#[Object]
impl TeamChangedAPI {
  async fn id(&self) -> &str {
    &self.0
  }

  async fn team(&self) -> FieldResult<Option<TeamAPI>> {
    let team = match Team::get(&self.0).await {
      Ok(t) => t,
      Err(e) => {
        log::error!("Failed to get team: {}", e);
        return Err(e.into());
      }
    };

    match team {
      Some(team) => Ok(Some(TeamAPI(self.0.clone(), team))),
      None => Ok(None),
    }
  }
}
