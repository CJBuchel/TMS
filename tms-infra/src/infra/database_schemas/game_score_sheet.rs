use std::collections::HashMap;

use crate::{DataSchemeExtensions, QuestionAnswer};
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use super::TmsDateTime;

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct GameScoreSheet {
  pub blueprint_title: String,
  pub table: String,
  pub team_ref_id: String, // team id in db, not team number
  pub referee: String,
  pub match_number: Option<String>,
  pub timestamp: TmsDateTime,

  // score sheet headers
  pub gp: String,
  pub no_show: bool,
  pub score: i32,
  pub round: u32,

  // score sheet data
  pub is_agnostic: bool,
  pub score_sheet_answers: Vec<QuestionAnswer>, // populated if not agnostic

  // referee comments
  pub private_comment: String,

  pub modified: bool,
  pub modified_by: Option<String>, // username
}

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub enum GameScoreSheetComparison {
  Better,
  Worse,
  Equal,
}

impl GameScoreSheet {
  pub fn compare(&self, other: GameScoreSheet) -> GameScoreSheetComparison {
    if self.score > other.score {
      GameScoreSheetComparison::Better
    } else if self.score < other.score {
      GameScoreSheetComparison::Worse
    } else {
      GameScoreSheetComparison::Equal
    }
  }

  // compare two lists of score sheets to find out which one is better
  // we use the highest score from each list to determine which one is better
  // if they are equal, we compare the second highest score, and so on
  pub fn compare_list(current: Vec<GameScoreSheet>, previous: Vec<GameScoreSheet>) -> GameScoreSheetComparison {
    
    // Case 1: current list is empty, previous list is not
    if current.len() == 0 && previous.len() > 0 {
      return GameScoreSheetComparison::Worse;
    }

    // Case 2: previous list is empty, current list is not
    if previous.len() == 0 && current.len() > 0 {
      return GameScoreSheetComparison::Better;
    }

    // Case 3: both lists are empty
    if previous.len() == 0 && current.len() == 0 {
      return GameScoreSheetComparison::Equal;
    }

    // Case 4: both lists have scores sheets
    let mut scores_a: Vec<i32> = current.iter().map(|s| s.score).collect::<Vec<i32>>();
    scores_a.sort_by(|a, b| b.cmp(a));

    let mut scores_b: Vec<i32> = previous.iter().map(|s| s.score).collect::<Vec<i32>>();
    scores_b.sort_by(|a, b| b.cmp(a));

    let mut index = 0;

    while index < scores_a.len() && index < scores_b.len() {
      let score_a = scores_a.get(index).unwrap_or(&0);
      let score_b = scores_b.get(index).unwrap_or(&0);

      if score_a > score_b {
        return GameScoreSheetComparison::Better;
      } else if score_a < score_b {
        return GameScoreSheetComparison::Worse;
      }

      index += 1;
    }

    return GameScoreSheetComparison::Equal;
  }

  // provides list of (team_id, rank)
  pub fn calculate_team_rankings(score_sheets: Vec<GameScoreSheet>) -> HashMap<String, u32> {
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

    // sort based on the comparison results
    team_score_sheets_vec.sort_by(|a, b| {
      match GameScoreSheet::compare_list(a.1.clone(), b.1.clone()) {
        GameScoreSheetComparison::Better => std::cmp::Ordering::Greater,
        GameScoreSheetComparison::Worse => std::cmp::Ordering::Less,
        GameScoreSheetComparison::Equal => std::cmp::Ordering::Equal,
      }
    });

    // assign rankings to each team
    let mut ranked_teams: HashMap<String, u32> = HashMap::new();
    let mut rank: u32 = 1;
    let mut prev_team: Option<&(String, Vec<GameScoreSheet>)> = None;

    for team in &team_score_sheets_vec {
      if let Some(prev) = prev_team {
        if let GameScoreSheetComparison::Worse = GameScoreSheet::compare_list(team.1.clone(), prev.1.clone()) {
          rank += 1;
        }
      }
      ranked_teams.insert(team.0.clone(), rank);
      prev_team = Some(team);
    }

    ranked_teams
  }
}

impl Default for GameScoreSheet {
  fn default() -> Self {
    Self {
      blueprint_title: "".to_string(),
      table: "".to_string(),
      team_ref_id: "".to_string(),
      referee: "".to_string(),
      match_number: None,
      timestamp: TmsDateTime::default(),
      gp: "".to_string(),
      no_show: false,
      score: 0,
      round: 0,
      is_agnostic: false,
      score_sheet_answers: Vec::new(),
      private_comment: "".to_string(),
      modified: false,
      modified_by: None,
    }
  }
}

impl DataSchemeExtensions for GameScoreSheet {}