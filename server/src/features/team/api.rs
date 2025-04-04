use async_graphql::{FieldResult, Object, Subscription};
use database::TableBroker;
use tokio_stream::Stream;

use crate::api::RecordChangedAPI;

use super::{model::Team, TeamRepository};

pub struct TeamAPI(pub String, pub Team);

//
// API Types
//
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

//
// Queries
//
#[derive(Default)]
pub struct TeamQueries;
#[Object]
impl TeamQueries {
  async fn team(&self, id: String) -> FieldResult<TeamAPI> {
    let team = match Team::get(&id).await {
      Ok(team) => team,
      Err(e) => {
        log::error!("Failed to get team: {}", e);
        return Err(e.into());
      }
    };

    let team = match team {
      Some(team) => team,
      None => return Err("Team not found".into()),
    };

    Ok(TeamAPI(id, team))
  }

  async fn teams(&self) -> FieldResult<Vec<TeamAPI>> {
    let teams = match Team::get_all().await {
      Ok(teams) => teams,
      Err(e) => {
        log::error!("Failed to get teams: {}", e);
        return Err(e.into());
      }
    };

    Ok(teams.into_iter().map(|(id, team)| TeamAPI(id, team)).collect())
  }
}

//
// Mutations
//
#[derive(Default)]
pub struct TeamMutations;
#[Object]
impl TeamMutations {
  pub async fn add_team(&self, team: Team) -> FieldResult<TeamAPI> {
    let (id, team) = match Team::add(&team).await {
      Ok(id) => id,
      Err(e) => {
        log::error!("Failed to create team: {}", e);
        return Err(e.into());
      }
    };

    Ok(TeamAPI(id, team))
  }

  pub async fn remove_team(&self, id: String) -> FieldResult<bool> {
    match Team::remove(&id).await {
      Ok(_) => Ok(true),
      Err(e) => {
        log::error!("Failed to remove team: {}", e);
        Err(e.into())
      }
    }
  }
}

//
// Subscriptions
//
#[derive(Default)]
pub struct TeamSubscriptions;
#[Subscription]
impl TeamSubscriptions {
  async fn team_changes(&self) -> impl Stream<Item = RecordChangedAPI<TeamAPI>> {
    TableBroker::<Team>::subscribe_transform(|change| {
      let team = change.1.map(|team| TeamAPI(change.0.clone(), team));
      RecordChangedAPI::<TeamAPI>::new(change.0, team)
    })
  }
}
