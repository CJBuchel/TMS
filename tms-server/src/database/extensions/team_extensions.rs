use tms_infra::*;

use crate::database::{Database, TEAMS};
pub use echo_tree_rs::core::*;
use uuid::Uuid;

#[async_trait::async_trait]
pub trait TeamExtensions {
  async fn get_team(&self, team_id: String) -> Option<Team>;
  async fn get_team_by_number(&self, number: String) -> Option<(String, Team)>;
  async fn insert_team(&self, team: Team, team_id: Option<String>) -> Result<(), String>;
  async fn remove_team(&self, team_id: String) -> Result<(), String>;
  async fn update_team_rank(&self, team_id: String, rank: u32) -> Result<(), String>;
  async fn calculate_team_rankings(&self, score_sheets: Vec<GameScoreSheet>) -> Result<(), String>;
}

#[async_trait::async_trait]
impl TeamExtensions for Database {
  async fn get_team(&self, team_id: String) -> Option<Team> {
    let tree = self.inner.read().await.get_tree(TEAMS.to_string()).await;
    let team = tree.get(&team_id).cloned();

    match team {
      Some(team) => Some(Team::from_json_string(&team)),
      None => None,
    }
  }

  async fn get_team_by_number(&self, number: String) -> Option<(String, Team)> {
    let tree = self.inner.read().await.get_tree(TEAMS.to_string()).await;
    let team = tree.iter().find_map(|(id, team)| {
      let team = Team::from_json_string(team);
      if team.team_number == number {
        Some((id.clone(), team))
      } else {
        None
      }
    });

    match team {
      Some((id, team)) => Some((id, team)),
      None => None,
    }
  }

  async fn insert_team(&self, team: Team, team_id: Option<String>) -> Result<(), String> {
    // check if team already exists (using id if provided, otherwise using number)
    let existing_team: Option<(String, Team)> = match team_id {
      Some(team_id) => self.get_team(team_id.clone()).await.map(|team| (team_id, team)),
      None => self.get_team_by_number(team.clone().team_number).await,
    };

    match existing_team {
      Some((team_id, _)) => {
        log::warn!("Team already exists: {}, overwriting with insert...", team_id);
        self.inner.write().await.insert_entry(TEAMS.to_string(), team_id, team.to_json_string()).await;
        Ok(())
      }
      None => {
        self.inner.write().await.insert_entry(TEAMS.to_string(), Uuid::new_v4().to_string(), team.to_json_string()).await;
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
      None => Err(format!("Team with id {} not found", team_id)),
    }
  }

  async fn update_team_rank(&self, team_id: String, rank: u32) -> Result<(), String> {
    let tree = self.inner.read().await.get_tree(TEAMS.to_string()).await;
    let team = tree.get(&team_id).cloned();

    match team {
      Some(team) => {
        let mut team = Team::from_json_string(&team);
        team.ranking = rank;
        self.inner.write().await.insert_entry(TEAMS.to_string(), team_id, team.to_json_string()).await;
        Ok(())
      }
      None => Err(format!("Team with id {} not found", team_id)),
    }
  }

  async fn calculate_team_rankings(&self, score_sheets: Vec<GameScoreSheet>) -> Result<(), String> {
    // get all team scoresheets
    let team_rankings = GameScoreSheet::calculate_team_rankings(score_sheets);
    for (team_id, rank) in team_rankings {
      self.update_team_rank(team_id, rank).await?;
    }
    Ok(())
  }
}
