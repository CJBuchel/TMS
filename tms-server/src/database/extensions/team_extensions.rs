use tms_infra::{DataSchemeExtensions, Team};

pub use echo_tree_rs::core::*;
use uuid::Uuid;
use crate::database::{Database, TEAMS};


#[async_trait::async_trait]
pub trait TeamExtensions {
  async fn get_team(&self, team_id: String) -> Option<Team>;
  async fn get_team_by_number(&self, number: String) -> Option<(String, Team)>;
  async fn insert_team(&self, team: Team, team_id: Option<String>) -> Result<(), String>;
  async fn remove_team(&self, team_id: String) -> Result<(), String>;
}

#[async_trait::async_trait]
impl TeamExtensions for Database {
  async fn get_team(&self, team_id: String) -> Option<Team> {
    let tree = self.inner.read().await.get_tree(TEAMS.to_string()).await;
    let team = tree.get(&team_id).cloned();

    match team {
      Some(team) => {
        Some(Team::from_json(&team))
      }
      None => None,
    }
  }

  async fn get_team_by_number(&self, number: String) -> Option<(String, Team)> {
    let tree = self.inner.read().await.get_tree(TEAMS.to_string()).await;
    let team = tree.iter().find_map(|(id, team)| {
      let team = Team::from_json(team);
      if team.number == number {
        Some((id.clone(), team))
      } else {
        None
      }
    });

    match team {
      Some((id, team)) => {
        Some((id, team))
      }
      None => None,
    }
  }

  async fn insert_team(&self, team: Team, team_id: Option<String>) -> Result<(), String> {
    // check if team already exists (using id if provided, otherwise using number)
    let existing_team: Option<(String, Team)> = match team_id {
      Some(team_id) => self.get_team(team_id.clone()).await.map(|team| (team_id, team)),
      None => self.get_team_by_number(team.clone().number).await,
    }; 

    match existing_team {
      Some((team_id, team)) => {
        log::warn!("Team already exists: {}, overwriting with insert...", team_id);
        self.inner.write().await.insert_entry(TEAMS.to_string(), team_id, team.to_json()).await;
        Ok(())
      },
      None => {
        self.inner.write().await.insert_entry(TEAMS.to_string(), Uuid::new_v4().to_string(), team.to_json()).await;
        Ok(())
      }
    }
  }

  async fn remove_team(&self, team_id: String) -> Result<(), String> {
    let tree = self.inner.read().await.get_tree(TEAMS.to_string()).await;
    let team = tree.get(&team_id).cloned();

    match team {
      Some(_) => {
        self.inner.write().await.remove_entry(TEAMS.to_string(), team_id).await;
        Ok(())
      }
      None => {
        Err(format!("Team with id {} not found", team_id))
      }
    }
  }
}