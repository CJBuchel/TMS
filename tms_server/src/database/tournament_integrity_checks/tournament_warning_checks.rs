use std::collections::HashMap;

use tms_infra::*;

pub struct TournamentWarningChecks;

impl TournamentWarningChecks {
  pub fn get_integrity_messages(teams: HashMap<String, Team>, game_matches: HashMap<String, GameMatch>, game_scores: HashMap<String, GameScoreSheet>, judging_sessions: HashMap<String, JudgingSession>) -> Vec<TournamentIntegrityMessage> {
    let mut messages = Vec::new();

    // W001, W002, W003
    {
      let mut team_names = HashMap::new();
      for (team_id, team) in teams.iter() {
        // check for missing team names W001
        if team.name.is_empty() {
          messages.push(TournamentIntegrityMessage::new(TournamentIntegrityCode::Warning(TournamentWarningCode::W001), Some(team.team_number.clone()), None, None));
        }

        // check for duplicate team names W002
        if team_names.contains_key(&team.name) {
          messages.push(TournamentIntegrityMessage::new(TournamentIntegrityCode::Warning(TournamentWarningCode::W002), Some(team.team_number.clone()), None, None));
        } else {
          team_names.insert(team.name.clone(), true);
        }

        // get the scores for the team
        let team_scores = game_scores.iter().filter(|(_, score)| score.team_ref_id == *team_id).collect::<Vec<_>>();

        // check for round 0 scores W003
        for (_, score) in team_scores.iter() {
          if score.round == 0 {
            messages.push(TournamentIntegrityMessage::new(TournamentIntegrityCode::Warning(TournamentWarningCode::W003), Some(team.team_number.clone()), None, None));
          }
        }
      }
    }

    // W004, W005, W006, W007, W008, W009
    {
      for (_, game_match) in game_matches.iter() {
        // check for no tables or teams found in match W004
        if game_match.game_match_tables.is_empty() {
          messages.push(TournamentIntegrityMessage::new(
            TournamentIntegrityCode::Warning(TournamentWarningCode::W004),
            None,
            Some(game_match.match_number.clone()),
            None,
          ));
        }

        for on_table in game_match.game_match_tables.iter() {
          // check for match complete but score not submitted W005
          if game_match.completed && !on_table.score_submitted {
            messages.push(TournamentIntegrityMessage::new(
              TournamentIntegrityCode::Warning(TournamentWarningCode::W005),
              Some(on_table.team_number.clone()),
              Some(game_match.match_number.clone()),
              None,
            ));
          }

          // check for match not complete but score submitted W006
          if !game_match.completed && on_table.score_submitted {
            messages.push(TournamentIntegrityMessage::new(
              TournamentIntegrityCode::Warning(TournamentWarningCode::W006),
              Some(on_table.team_number.clone()),
              Some(game_match.match_number.clone()),
              None,
            ));
          }

          // check for blank table in match W007
          if on_table.table.is_empty() {
            messages.push(TournamentIntegrityMessage::new(
              TournamentIntegrityCode::Warning(TournamentWarningCode::W007),
              Some(on_table.team_number.clone()),
              Some(game_match.match_number.clone()),
              None,
            ));
          }

          // check for no team on table W008
          if on_table.team_number.is_empty() {
            messages.push(TournamentIntegrityMessage::new(
              TournamentIntegrityCode::Warning(TournamentWarningCode::W008),
              None,
              Some(game_match.match_number.clone()),
              None,
            ));
          }

          // check if team in this match has judging session within 10 minutes of match W009
          {
            let match_start_time = game_match.start_time.clone();
            let match_end_time = game_match.end_time.clone();
            // get the judging sessions for team
            let team_judging_sessions = judging_sessions
              .iter()
              .filter(|(_, judging_session)| judging_session.judging_session_pods.iter().any(|pod| pod.team_number == on_table.team_number))
              .collect::<Vec<_>>();
            // check if the judging session is within 10 minutes of the match
            for (_, judging_session) in team_judging_sessions.iter() {
              let judging_start_time = judging_session.start_time.clone();
              let judging_end_time = judging_session.end_time.clone();

              // Check if the match ends within 10 minutes before the judging session starts
              let ends_within_10_minutes_of_judging_start =  match_end_time.is_before(judging_start_time.clone()) && judging_start_time.difference(match_end_time.clone()).in_minutes() <= 10;

              // Check if the match starts within 10 minutes after the judging session ends
              let starts_within_10_minutes_of_judging_end = match_start_time.is_after(judging_end_time.clone()) && match_start_time.difference(judging_end_time.clone()).in_minutes() <= 10;

              if ends_within_10_minutes_of_judging_start || starts_within_10_minutes_of_judging_end {
                messages.push(TournamentIntegrityMessage::new(
                  TournamentIntegrityCode::Warning(TournamentWarningCode::W009),
                  Some(on_table.team_number.clone()),
                  Some(game_match.match_number.clone()),
                  Some(judging_session.session_number.clone()),
                ));
              }
            }
          }
        }
      }
    }

    // W010
    {
      for (_, judging_session) in judging_sessions.iter() {
        // check for no teams/pods found in sessions W010
        if judging_session.judging_session_pods.is_empty() {
          messages.push(TournamentIntegrityMessage::new(
            TournamentIntegrityCode::Warning(TournamentWarningCode::W010),
            None,
            None,
            Some(judging_session.session_number.clone()),
          ));
        }

        for pod in judging_session.judging_session_pods.iter() {
          // check for session complete but no core values score submitted W011
          if judging_session.completed && !pod.core_values_submitted {
            messages.push(TournamentIntegrityMessage::new(
              TournamentIntegrityCode::Warning(TournamentWarningCode::W011),
              Some(pod.team_number.clone()),
              None,
              Some(judging_session.session_number.clone()),
            ));
          }

          // check for session complete but no innovation score submitted W012
          if judging_session.completed && !pod.innovation_submitted {
            messages.push(TournamentIntegrityMessage::new(
              TournamentIntegrityCode::Warning(TournamentWarningCode::W012),
              Some(pod.team_number.clone()),
              None,
              Some(judging_session.session_number.clone()),
            ));
          }

          // check for session complete but no robot design score submitted W013
          if judging_session.completed && !pod.robot_design_submitted {
            messages.push(TournamentIntegrityMessage::new(
              TournamentIntegrityCode::Warning(TournamentWarningCode::W013),
              Some(pod.team_number.clone()),
              None,
              Some(judging_session.session_number.clone()),
            ));
          }

          // check for session not complete but core values score submitted W014
          if !judging_session.completed && pod.core_values_submitted {
            messages.push(TournamentIntegrityMessage::new(
              TournamentIntegrityCode::Warning(TournamentWarningCode::W014),
              Some(pod.team_number.clone()),
              None,
              Some(judging_session.session_number.clone()),
            ));
          }

          // check for session not complete but innovation score submitted W015
          if !judging_session.completed && pod.innovation_submitted {
            messages.push(TournamentIntegrityMessage::new(
              TournamentIntegrityCode::Warning(TournamentWarningCode::W015),
              Some(pod.team_number.clone()),
              None,
              Some(judging_session.session_number.clone()),
            ));
          }

          // check for session not complete but robot design score submitted W016
          if !judging_session.completed && pod.robot_design_submitted {
            messages.push(TournamentIntegrityMessage::new(
              TournamentIntegrityCode::Warning(TournamentWarningCode::W016),
              Some(pod.team_number.clone()),
              None,
              Some(judging_session.session_number.clone()),
            ));
          }

          // check for blank pod in session
          if pod.pod_name.is_empty() {
            messages.push(TournamentIntegrityMessage::new(
              TournamentIntegrityCode::Warning(TournamentWarningCode::W017),
              Some(pod.team_number.clone()),
              None,
              Some(judging_session.session_number.clone()),
            ));
          }

          // check for no team in pod
          if pod.team_number.is_empty() {
            messages.push(TournamentIntegrityMessage::new(
              TournamentIntegrityCode::Warning(TournamentWarningCode::W018),
              None,
              None,
              Some(judging_session.session_number.clone()),
            ));
          }
        }
      }
    }

    if !messages.is_empty() {
      // print the messages
      for message in messages.iter() {
        log::warn!("{}", message.message);
      }
    }
    return messages;
  }
}
