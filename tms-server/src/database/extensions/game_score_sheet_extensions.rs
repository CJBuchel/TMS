use std::collections::HashMap;

use crate::database::{Database, ROBOT_GAME_SCORES};
pub use echo_tree_rs::core::*;
use tms_infra::*;
use uuid::Uuid;

use super::{TeamExtensions, TournamentBlueprintExtensions};

#[async_trait::async_trait]
pub trait GameScoreSheetExtensions {
  async fn get_game_score_sheet(&self, game_score_sheet_id: String) -> Option<GameScoreSheet>;
  async fn get_game_score_sheets_by_team(&self, team_id: String) -> HashMap<String, GameScoreSheet>;
  async fn insert_game_score_sheet(&self, game_score_sheet: GameScoreSheet, game_score_sheet_id: Option<String>) -> Result<(), String>;
  async fn remove_game_score_sheet(&self, game_score_sheet_id: String) -> Result<(), String>;
  async fn update_rankings(&self) -> Result<(), String>;
}

#[async_trait::async_trait]
impl GameScoreSheetExtensions for Database {
  async fn get_game_score_sheet(&self, game_score_sheet_id: String) -> Option<GameScoreSheet> {
    let tree = self.inner.read().await.get_tree(ROBOT_GAME_SCORES.to_string()).await;
    let game_score_sheet = tree.get(&game_score_sheet_id).cloned();

    match game_score_sheet {
      Some(game_score_sheet) => Some(GameScoreSheet::from_json_string(&game_score_sheet)),
      None => None,
    }
  }

  async fn get_game_score_sheets_by_team(&self, team_id: String) -> HashMap<String, GameScoreSheet> {
    let tree = self.inner.read().await.get_tree(ROBOT_GAME_SCORES.to_string()).await;
    let game_score_sheets: HashMap<String, GameScoreSheet> = tree.iter().filter_map(|(game_score_sheet_id, game_score_sheet)| {
      let game_score_sheet = GameScoreSheet::from_json_string(game_score_sheet);
      if game_score_sheet.team_ref_id == team_id {
        Some((game_score_sheet_id.clone(), game_score_sheet))
      } else {
        None
      }
    }).collect();
    game_score_sheets
  }

  async fn insert_game_score_sheet(&self, mut game_score_sheet: GameScoreSheet, game_score_sheet_id: Option<String>) -> Result<(), String> {
    if game_score_sheet.no_show {
      game_score_sheet.score = 0;
    }

    // if this is not an agnostic score sheet, pass the answers through the calculator and validate system
    if !game_score_sheet.is_agnostic && !game_score_sheet.no_show {
      match self.get_blueprint_by_title(game_score_sheet.blueprint_title.clone()).await {
        Some((_, blueprint)) => {
          // validate answers
          let errors = FllBlueprintMap::validate(blueprint.title.clone(), game_score_sheet.score_sheet_answers.to_owned());

          // if any errors return error
          if let Some(errors) = errors {
            if errors.len() > 0 {
              let stringified_errors = errors.iter().map(|e| format!("{} : {}", e.question_ids, e.message)).collect::<Vec<String>>().join("\n");
              return Err(stringified_errors);
            }
          }

          // modify the score sheet to include the calculated score
          let score = FllBlueprintMap::calculate_score(blueprint.blueprint, game_score_sheet.score_sheet_answers.to_owned());
          game_score_sheet.score = score;
          log::warn!("Calculated score for: {}, {}", game_score_sheet.table , score);
        }
        None => {
          return Err("Blueprint does not exist".to_string());
        }
      }
    }

    // check if game_score_sheet already exists (using id if provided, otherwise using number)
    let existing_game_score_sheet: Option<(String, GameScoreSheet)> = match game_score_sheet_id {
      Some(game_score_sheet_id) => self.get_game_score_sheet(game_score_sheet_id.clone()).await.map(|game_score_sheet| (game_score_sheet_id, game_score_sheet)),
      None => None,
    };

    match existing_game_score_sheet {
      Some((game_score_sheet_id, _)) => {
        log::warn!("GameScoreSheet already exists: {}, overwriting with insert...", game_score_sheet_id);
        self.inner.write().await.insert_entry(ROBOT_GAME_SCORES.to_string(), game_score_sheet_id, game_score_sheet.to_json_string()).await;
      }
      None => {
        self.inner.write().await.insert_entry(ROBOT_GAME_SCORES.to_string(), Uuid::new_v4().to_string(), game_score_sheet.to_json_string()).await;
      }
    }

    // update rankings
    return self.update_rankings().await;
  }

  async fn update_rankings(&self) -> Result<(), String> {
    log::warn!("Updating rankings...");
    // get all team score sheets
    let tree = self.inner.read().await.get_tree(ROBOT_GAME_SCORES.to_string()).await;
    let game_score_sheets = tree.iter().map(|(_, game_score_sheet)| GameScoreSheet::from_json_string(game_score_sheet)).collect::<Vec<GameScoreSheet>>();
    // calculate team rankings
    self.calculate_team_rankings(game_score_sheets).await?;
    Ok(())
  }

  async fn remove_game_score_sheet(&self, game_score_sheet_id: String) -> Result<(), String> {
    let tree = self.inner.read().await.get_tree(ROBOT_GAME_SCORES.to_string()).await;
    let game_score_sheet = tree.get(&game_score_sheet_id).cloned();

    match game_score_sheet {
      Some(_) => {
        self.inner.write().await.remove_entry(ROBOT_GAME_SCORES.to_string(), game_score_sheet_id).await;
        // update rankings
        return self.update_rankings().await;
      }
      None => {
        log::warn!("GameScoreSheet does not exist: {}", game_score_sheet_id);
        Err(format!("GameScoreSheet does not exist: {}", game_score_sheet_id))
      }
    }
  }
}
