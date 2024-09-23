use std::collections::HashMap;

use tms_infra::*;

use super::{tournament_error_checks::TournamentErrorChecks, tournament_warning_checks::TournamentWarningChecks};

pub struct TournamentIntegrityCheck;

impl TournamentIntegrityCheck {
  pub fn get_integrity_messages(
    teams: HashMap<String, Team>,
    game_matches: HashMap<String, GameMatch>,
    game_match_tables: HashMap<String, GameTable>,
    game_scores: HashMap<String, GameScoreSheet>,
    judging_sessions: HashMap<String, JudgingSession>,
    judging_session_pods: HashMap<String, JudgingPod>,
  ) -> Vec<TournamentIntegrityMessage> {
    let mut messages = Vec::new();
    // get errors
    let errors = TournamentErrorChecks::get_integrity_messages(
      teams.clone(),
      game_matches.clone(),
      game_match_tables.clone(),
      game_scores.clone(),
      judging_sessions.clone(),
      judging_session_pods.clone(),
    );

    // add errors to messages
    messages.extend(errors);

    // get warnings
    let warnings = TournamentWarningChecks::get_integrity_messages(
      teams.clone(),
      game_matches.clone(),
      game_scores.clone(),
      judging_sessions.clone(),
    );

    // add warnings to messages
    messages.extend(warnings);

    return messages;
  }
}