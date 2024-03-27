use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use super::{TeamGameScore, TeamJudgingScore};
#[derive(JsonSchema, Deserialize, Serialize, Clone, Default)]
pub struct Team {
  pub team_number: String,
  pub team_name: String,
  pub team_affiliation: String,
  pub team_id: String,
  pub game_scores: Vec<TeamGameScore>,
  pub core_values_scores: Vec<TeamJudgingScore>,
  pub innovation_project_scores: Vec<TeamJudgingScore>,
  pub robot_design_scores: Vec<TeamJudgingScore>,
  pub ranking: u32
}


pub enum TeamCompareResult {
  Better,
  Worse,
  Equal
}

impl Team {
  pub fn get_sorted_game_scores(&self) -> Vec<i32> {
    let mut scores: Vec<i32> = self.game_scores.iter().map(|game| game.score).collect();
    scores.sort_by(|a, b| b.cmp(a));
    scores
  }

  // returns 1 if self is better than team_b, -1 if team_b is better than self, and 0 if they are equal
  pub fn compare(&self, team_b: &Team) -> TeamCompareResult {

    // Case 1: self has no scores but team_b does
    if self.game_scores.is_empty() && !team_b.game_scores.is_empty() {
      return TeamCompareResult::Worse;
    }

    // Case 2: self has scores but team_b does not
    if !self.game_scores.is_empty() && team_b.game_scores.is_empty() {
      return TeamCompareResult::Better;
    }

    // Case 3: Both teams have no scores
    if self.game_scores.is_empty() && team_b.game_scores.is_empty() {
      return TeamCompareResult::Equal;
    }

    // Case 4: Both teams have scores
    let scores_a = self.get_sorted_game_scores();
    let scores_b = team_b.get_sorted_game_scores();
    let mut index = 0;

    while index < scores_a.len() || index < scores_b.len() {
      let score_a = scores_a.get(index).unwrap_or(&0);
      let score_b = scores_b.get(index).unwrap_or(&0);

      if score_a > score_b {
          return TeamCompareResult::Better;
      } else if score_a < score_b {
          return TeamCompareResult::Worse;
      }

      index += 1;
    }

    // If both score vectors are entirely equal, they are of the same rank.
    return TeamCompareResult::Equal;
  }
}

pub fn rank_teams(mut teams: Vec<Team>) -> Vec<Team> {
  // sort the teams
  teams.sort_by(|a, b| match b.compare(a) {
    TeamCompareResult::Better => std::cmp::Ordering::Greater,
    TeamCompareResult::Worse => std::cmp::Ordering::Less,
    TeamCompareResult::Equal => std::cmp::Ordering::Equal,
  });

  let mut rank: u32 = 1;
  let mut prev_team: Option<&Team> = None;
  for team in &mut teams {
    if let Some(prev) = prev_team {
      if let TeamCompareResult::Worse = team.compare(prev) {
        rank += 1;
      }
    }
    team.ranking = rank;
    prev_team = Some(team);
  }

  teams
}