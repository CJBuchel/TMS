use std::collections::HashMap;

use tms_infra::*;

pub struct TournamentErrorChecks;

impl TournamentErrorChecks {
  pub fn get_integrity_messages(
    teams: HashMap<String, Team>,
    game_matches: HashMap<String, GameMatch>,
    game_match_tables: HashMap<String, GameTable>,
    game_scores: HashMap<String, GameScoreSheet>,
    judging_sessions: HashMap<String, JudgingSession>,
    judging_session_pods: HashMap<String, JudgingPod>,
  ) -> Vec<TournamentIntegrityMessage> {
    let mut messages = Vec::new();

    // Check for missing team numbers E001
    {
      for (_, team) in teams.iter() {
        if team.team_number.is_empty() {
          messages.push(TournamentIntegrityMessage::new(
            TournamentIntegrityCode::Error(TournamentErrorCode::E001),
            Some(team.team_number.clone()),
            None,
            None,
          ));
        }
      }
    }

    // check for duplicate team numbers E002
    {
      let mut team_numbers = HashMap::new();
      for (_, team) in teams.iter() {
        if team_numbers.contains_key(&team.team_number) {
          messages.push(TournamentIntegrityMessage::new(
            TournamentIntegrityCode::Error(TournamentErrorCode::E002),
            Some(team.team_number.clone()),
            None,
            None,
          ));
        } else {
          team_numbers.insert(team.team_number.clone(), true);
        }
      }
    }

    // check for conflicting scores/rounds E003
    {
      for (team_id, team) in teams.iter() {
        // get the scores for the team
        let team_scores = game_scores
          .iter()
          .filter(|(_, score)| score.team_ref_id == *team_id)
          .collect::<Vec<_>>();
  
        // check that the rounds are unique
        let mut rounds = HashMap::new();
        for (_, score) in team_scores.iter() {
          if rounds.contains_key(&score.round) {
            messages.push(TournamentIntegrityMessage::new(
              TournamentIntegrityCode::Error(TournamentErrorCode::E003),
              Some(team.team_number.clone()),
              None,
              None,
            ));
          } else {
            rounds.insert(score.round, true);
          }
        }
      }
    }
    
    // E004, E005, E006
    {
      let mut match_numbers = HashMap::new();
      for (_, game_match) in game_matches.iter() {
        
        // check for tables that don't exist in matches E004
        for on_table in game_match.game_match_tables.iter() {
          let table_name = on_table.table.clone();
          if !game_match_tables.iter().any(|(_, table)| table.table_name == table_name) {
            messages.push(TournamentIntegrityMessage::new(
              TournamentIntegrityCode::Error(TournamentErrorCode::E004),
              Some(on_table.team_number.clone()),
              Some(game_match.match_number.clone()),
              None,
            ));
          }
  
          // check for teams that don't exist in matches E005
          let team_number = on_table.team_number.clone();
          if !teams.iter().any(|(_, team)| team.team_number == team_number) {
            messages.push(TournamentIntegrityMessage::new(
              TournamentIntegrityCode::Error(TournamentErrorCode::E005),
              Some(team_number.clone()),
              Some(game_match.match_number.clone()),
              None,
            ));
          }
        }
        
        // check for duplicate match numbers E006
        if match_numbers.contains_key(&game_match.match_number) {
          messages.push(TournamentIntegrityMessage::new(
            TournamentIntegrityCode::Error(TournamentErrorCode::E006),
            None,
            Some(game_match.match_number.clone()),
            None,
          ));
        } else {
          match_numbers.insert(game_match.match_number.clone(), true);
        }
      }
    }

    // count the number of matches for each team (get maximum number of rounds)
    {
      let mut max_rounds = 0;
      for (_, team) in teams.iter() {
        let mut team_matches = 0;
        for (_, game_match) in game_matches.iter() {
          for on_table in game_match.game_match_tables.iter() {
            if on_table.team_number == team.team_number {
              team_matches += 1;
            }
          }
        }
        if team_matches > max_rounds {
          max_rounds = team_matches;
        }
      }

      // check for teams with fewer matches than the maximum number of rounds E007
      for (_, team) in teams.iter() {
        let mut team_matches = 0;
        for (_, game_match) in game_matches.iter() {
          for on_table in game_match.game_match_tables.iter() {
            if on_table.team_number == team.team_number {
              team_matches += 1;
            }
          }
        }
        if team_matches < max_rounds {
          messages.push(TournamentIntegrityMessage::new(
            TournamentIntegrityCode::Error(TournamentErrorCode::E007),
            Some(team.team_number.clone()),
            None,
            None,
          ));
        }
      }
    }

    // E008, E009
    {
      for (_, judging_session) in judging_sessions.iter() {
        for pod in judging_session.judging_session_pods.iter() {
          // check for pods that don't exist in judging sessions E008
          if !judging_session_pods.iter().any(|(_, session_pod)| session_pod.pod_name == pod.pod_name) {
            log::error!("Pod not found in judging sessions: {}, found pods: {:?}", pod.pod_name, judging_session_pods.values().map(|pod| pod.pod_name.clone()).collect::<Vec<String>>());
            messages.push(TournamentIntegrityMessage::new(
              TournamentIntegrityCode::Error(TournamentErrorCode::E008),
              Some(pod.team_number.clone()),
              None,
              Some(judging_session.session_number.clone()),
            ));
          }
  
          // check if team exists in this event E009
          if !teams.iter().any(|(_, team)| team.team_number == pod.team_number) {
            messages.push(TournamentIntegrityMessage::new(
              TournamentIntegrityCode::Error(TournamentErrorCode::E009),
              Some(pod.team_number.clone()),
              None,
              Some(judging_session.session_number.clone()),
            ));
          }
        }

      }
    }

    // E010, E011
    {
      for (_, team) in teams.iter() {
        // let mut team_sessions = 0;
        let team_sessions = judging_sessions.iter().filter(|(_, session)| {
          session.judging_session_pods.iter().any(|pod| pod.team_number == team.team_number)
        }).count();

        if team_sessions > 1 {
          // check for teams that have more than one judging session E009
          messages.push(TournamentIntegrityMessage::new(
            TournamentIntegrityCode::Error(TournamentErrorCode::E010),
            Some(team.team_number.clone()),
            None,
            None,
          ));
        } else if team_sessions == 0 {
          // check for teams that are not in any judging sessions E011
          messages.push(TournamentIntegrityMessage::new(
            TournamentIntegrityCode::Error(TournamentErrorCode::E011),
            Some(team.team_number.clone()),
            None,
            None,
          ));
        }
      }
    }

    // check for duplicate session numbers E012
    {
      let mut session_numbers = HashMap::new();
      for (_, judging_session) in judging_sessions.iter() {
        if session_numbers.contains_key(&judging_session.session_number) {
          messages.push(TournamentIntegrityMessage::new(
            TournamentIntegrityCode::Error(TournamentErrorCode::E012),
            None,
            Some(judging_session.session_number.clone()),
            None,
          ));
        } else {
          session_numbers.insert(judging_session.session_number.clone(), true);
        }
      }
    }

    return messages;
  }
}