use std::collections::HashMap;

use tms_infra::*;
use tournament_integrity_check::TournamentIntegrityCheck;

use crate::database::*;

#[async_trait::async_trait]
pub trait TournamentIntegrityMessageExtensions {
  async fn check_integrity(&self);
}

#[async_trait::async_trait]
impl TournamentIntegrityMessageExtensions for Database {
  async fn check_integrity(&self) {
    let read_db = self.inner.read().await;

    // get trees (map them from the json to the struct)
    let teams = read_db.get_tree(TEAMS.to_string()).await.iter().map(|(id, team)| {
      (id.clone(), Team::from_json_string(team))
    }).collect::<HashMap<String, Team>>();

    let game_matches = read_db.get_tree(ROBOT_GAME_MATCHES.to_string()).await.iter().map(|(id, game_match)| {
      (id.clone(), GameMatch::from_json_string(game_match))
    }).collect::<HashMap<String, GameMatch>>();

    let game_match_tables = read_db.get_tree(ROBOT_GAME_TABLES.to_string()).await.iter().map(|(id, game_match_table)| {
      (id.clone(), GameTable::from_json_string(game_match_table))
    }).collect::<HashMap<String, GameTable>>();

    let game_scores = read_db.get_tree(ROBOT_GAME_SCORES.to_string()).await.iter().map(|(id, game_score)| {
      (id.clone(), GameScoreSheet::from_json_string(game_score))
    }).collect::<HashMap<String, GameScoreSheet>>();

    let judging_sessions = read_db.get_tree(JUDGING_SESSIONS.to_string()).await.iter().map(|(id, judging_session)| {
      (id.clone(), JudgingSession::from_json_string(judging_session))
    }).collect::<HashMap<String, JudgingSession>>();

    let judging_session_pods = read_db.get_tree(JUDGING_PODS.to_string()).await.iter().map(|(id, judging_session_pod)| {
      (id.clone(), JudgingPod::from_json_string(judging_session_pod))
    }).collect::<HashMap<String, JudgingPod>>();

    
    let new_messages: HashMap<String, String> = TournamentIntegrityCheck::get_integrity_messages(
      teams,
      game_matches,
      game_match_tables,
      game_scores,
      judging_sessions,
      judging_session_pods,
    ).iter().map(|message| {
      (uuid::Uuid::new_v4().to_string(), message.to_json_string())
    }).collect();
    
    let old_messages = read_db.get_tree(TOURNAMENT_INTEGRITY_MESSAGES.to_string()).await;

    let mut new_values: Vec<&String> = new_messages.values().collect();
    let mut old_values: Vec<&String> = old_messages.values().collect();

    // sort values
    new_values.sort();
    old_values.sort();

    // if message values are different, update the tree with the new messages
    if new_values != old_values {
      read_db.set_tree(TOURNAMENT_INTEGRITY_MESSAGES.to_string(), new_messages.to_owned()).await;
    }

    log::trace!("Tournament integrity check complete");
  }
}