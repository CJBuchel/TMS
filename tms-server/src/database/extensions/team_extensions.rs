use std::collections::HashMap;

use tms_infra::*;

use crate::database::{Database, TEAMS};
pub use echo_tree_rs::core::*;
use uuid::Uuid;

use super::{GameMatchExtensions, GameScoreSheetExtensions, JudgingSessionExtensions};

pub trait RankingUtilities {
  fn compare_list(a: &[GameScoreSheet], b: &[GameScoreSheet]) -> std::cmp::Ordering;
  fn calculate_team_rankings(score_sheets: Vec<GameScoreSheet>) -> std::collections::HashMap<String, u32>;
}

impl RankingUtilities for GameScoreSheet {
  // compare two lists of score sheets to find out which one is better
  // we use the highest score from each list to determine which one is better
  // if they are equal, we compare the second highest score, and so on
  fn compare_list(a: &[GameScoreSheet], b: &[GameScoreSheet]) -> std::cmp::Ordering {
    // Handle empty cases first
    if a.is_empty() && !b.is_empty() {
      return std::cmp::Ordering::Less;
    } else if b.is_empty() && !a.is_empty() {
      return std::cmp::Ordering::Greater;
    } else if a.is_empty() && b.is_empty() {
      return std::cmp::Ordering::Equal;
    }

    // Sort scores
    let mut scores_a: Vec<i32> = a.iter().map(|s| s.score).collect();
    let mut scores_b: Vec<i32> = b.iter().map(|s| s.score).collect();
    scores_a.sort_by(|a, b| b.cmp(a));  // Sort in descending order
    scores_b.sort_by(|a, b| b.cmp(a));

    // Compare sorted scores
    for (score_a, score_b) in scores_a.iter().zip(scores_b.iter()) {
      if score_a > score_b {
        return std::cmp::Ordering::Greater;
      } else if score_a < score_b {
        return std::cmp::Ordering::Less;
      }
    }

    std::cmp::Ordering::Equal
  }

  // provides list of (team_id, rank)
  fn calculate_team_rankings(score_sheets: Vec<GameScoreSheet>) -> HashMap<String, u32> {
    // Split the game_score_sheets into teams
    let mut team_score_sheets: HashMap<String, Vec<GameScoreSheet>> = HashMap::new();
    for game_score_sheet in score_sheets {
      team_score_sheets.entry(game_score_sheet.team_ref_id.clone())
        .or_insert_with(Vec::new)
        .push(game_score_sheet);
    }

    // Initialize a vector to store the team rankings (needed for sorting)
    let mut team_score_sheets_vec: Vec<(String, Vec<GameScoreSheet>)> = Vec::new();
    for (team_id, score_sheets) in team_score_sheets {
      team_score_sheets_vec.push((team_id, score_sheets));
    }
    team_score_sheets_vec.sort_by(|a, b| {
      GameScoreSheet::compare_list(&b.1, &a.1) // sort in ascending order (we want worst scores first)
    });

    // assign rankings to each team
    let mut ranked_teams: HashMap<String, u32> = HashMap::new();
    let mut rank: u32 = 1;
    let mut prev_team: Option<&(String, Vec<GameScoreSheet>)> = None;

    for team in &team_score_sheets_vec {
      if let Some(prev) = prev_team {
        if GameScoreSheet::compare_list(&team.1, &prev.1) == std::cmp::Ordering::Less {
          rank += 1;
        }
      }
      ranked_teams.insert(team.0.clone(), rank);
      prev_team = Some(team);
    }

    ranked_teams
  }
}

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
      }
      None => {
        self.inner.write().await.insert_entry(TEAMS.to_string(), Uuid::new_v4().to_string(), team.to_json_string()).await;
      }
    }

    Ok(())
  }

  async fn remove_team(&self, team_id: String) -> Result<(), String> {
    let tree = self.inner.read().await.get_tree(TEAMS.to_string()).await;
    let team = tree.get(&team_id).cloned();

    match team {
      Some(team_str) => {
        // convert team to struct
        let team = Team::from_json_string(&team_str);

        // remove team score sheets
        let score_sheets = self.get_game_score_sheets_by_team(team_id.clone()).await;

        for (game_score_sheet_id, _) in score_sheets {
          self.remove_game_score_sheet(game_score_sheet_id).await?;
        }

        // update and remove on table where this team exists
        let game_matches = self.get_game_matches_by_team_number(team.team_number.clone()).await;
        // update the matches and remove the game match tables where this team exists
        for (game_match_id, mut game_match) in game_matches {
          game_match.game_match_tables.retain(|table| table.team_number != team.team_number);
          self.insert_game_match(game_match, Some(game_match_id)).await?;
        }

        // update and remove in pod where this team exists
        let judging_sessions = self.get_judging_sessions_by_team_number(team.team_number.clone()).await;
        // update the judging sessions and remove the judging session pods where this team exists
        for (judging_session_id, mut judging_session) in judging_sessions {
          judging_session.judging_session_pods.retain(|pod| pod.team_number != team.team_number);
          self.insert_judging_session(judging_session, Some(judging_session_id)).await?;
        }

        // finally remove the team
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
    let team_rankings = GameScoreSheet::calculate_team_rankings(score_sheets);

    // determine the next rank for teams not in the ranking map
    let next_rank = team_rankings.values().max().unwrap_or(&0) + 1;

    let tree = self.inner.read().await.get_tree(TEAMS.to_string()).await;
    let team_ids = tree.iter().map(|(id, _)| id.clone()).collect::<Vec<String>>();

    for team_id in team_ids {
      let rank = team_rankings.get(&team_id).unwrap_or(&next_rank);
      self.update_team_rank(team_id, *rank).await?;
    }
    Ok(())
  }
}
