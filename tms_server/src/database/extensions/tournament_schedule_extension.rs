use std::collections::HashMap;

use tms_infra::TmsCategory;
use tms_schedule_handler::TmsSchedule;

use crate::database::Database;

// use super::{GameMatchCategoryExtensions, GameMatchExtensions, GameTableExtensions, JudgingPodExtensions, JudgingSessionExtensions, TeamExtensions};
use super::*;

#[async_trait::async_trait]
pub trait TournamentScheduleExtensions {
  async fn set_tournament_schedule(&mut self, schedule: TmsSchedule) -> Result<(), String>;
}

#[async_trait::async_trait]
impl TournamentScheduleExtensions for Database {
  async fn set_tournament_schedule(&mut self, schedule: TmsSchedule) -> Result<(), String> {
    // set teams
    for team in schedule.teams {
      match self.insert_team(team.clone(), None).await {
        Ok(_) => {
          log::info!("Inserted team: {}, name: {}, affiliation: {}", team.team_number, team.name, team.affiliation);
        }
        Err(e) => {
          log::error!("Error inserting team: {}", e);
          return Err(format!("Error inserting team: {}", e));
        }
      }
    }

    // set tables
    for table in schedule.game_tables {
      match self.insert_game_table(table.clone(), None).await {
        Ok(_) => {
          log::info!("Inserted table: {}", table);
        }
        Err(e) => {
          log::error!("Error inserting table: {}", e);
          return Err(format!("Error inserting table: {}", e));
        }
      }
    }

    // set matches
    for game_match in schedule.game_matches.to_owned() {
      match self.insert_game_match(game_match.clone(), None).await {
        Ok(_) => {
          log::info!("Inserted game match: {}", game_match.match_number);
        }
        Err(e) => {
          log::error!("Error inserting game match: {}", e);
          return Err(format!("Error inserting game match: {}", e));
        }
      }
    }

    // set game match categories (iterate through the matches, grab the categories, and insert them)
    let mut game_categories_map: HashMap<String, Vec<String>> = HashMap::new();
    for game_match in schedule.game_matches {
      let cat_name = game_match.category.category;
      let sub_categories = game_match.category.sub_categories;
      // Check if the category already exists in the map
      let entry = game_categories_map.entry(cat_name).or_insert_with(Vec::new);
      // Add the subcategories to the existing category
      for sub_cat in sub_categories {
        if !entry.contains(&sub_cat) {
          entry.push(sub_cat);
        }
      }
    }
    // Convert the HashMap back to a Vec<TmsCategory>
    let game_categories: Vec<TmsCategory> = game_categories_map.into_iter().map(|(category, sub_categories)| TmsCategory { category, sub_categories }).collect();
    // add them to the db
    for category in game_categories {
      match self.insert_game_match_category(category.clone(), None).await {
        Ok(_) => {
          log::info!("Inserted game match category: {}", category.category);
        }
        Err(e) => {
          log::error!("Error inserting game match category: {}", e);
          return Err(format!("Error inserting game match category: {}", e));
        }
      }
    }

    // set pods
    for pod in schedule.judging_pods {
      match self.insert_judging_pod(pod.clone(), None).await {
        Ok(_) => {
          log::info!("Inserted judging pod: {}", pod);
        }
        Err(e) => {
          log::error!("Error inserting judging pod: {}", e);
          return Err(format!("Error inserting judging pod: {}", e));
        }
      }
    }

    // set sessions
    for session in schedule.judging_sessions.to_owned() {
      match self.insert_judging_session(session.clone(), None).await {
        Ok(_) => {
          log::info!("Inserted judging session: {}", session.session_number);
        }
        Err(e) => {
          log::error!("Error inserting judging session: {}", e);
          return Err(format!("Error inserting judging session: {}", e));
        }
      }
    }

    // set judging categories
    let mut judging_categories_map: HashMap<String, Vec<String>> = HashMap::new();
    for session in schedule.judging_sessions {
      let cat_name = session.category.category;
      let sub_categories = session.category.sub_categories;
      // Check if the category already exists in the map
      let entry = judging_categories_map.entry(cat_name).or_insert_with(Vec::new);
      // Add the subcategories to the existing category
      for sub_cat in sub_categories {
        if !entry.contains(&sub_cat) {
          entry.push(sub_cat);
        }
      }
    }

    // Convert the HashMap back to a Vec<TmsCategory>
    let judging_categories: Vec<TmsCategory> = judging_categories_map.into_iter().map(|(category, sub_categories)| TmsCategory { category, sub_categories }).collect();
    // add them to the db
    for category in judging_categories {
      match self.insert_judging_category(category.clone(), None).await {
        Ok(_) => {
          log::info!("Inserted judging category: {}", category.category);
        }
        Err(e) => {
          log::error!("Error inserting judging category: {}", e);
          return Err(format!("Error inserting judging category: {}", e));
        }
      }
    }

    self.check_integrity().await;

    Ok(())
  }
}
