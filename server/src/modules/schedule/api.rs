use std::collections::HashMap;
use tonic::{Request, Response, Result, Status};

use crate::{
  auth::auth_helpers::require_permission,
  generated::{
    api::{UploadScheduleCsvRequest, UploadScheduleCsvResponse, schedule_service_server::ScheduleService},
    common::Role,
    db::{GameMatch, JudgingSession, MatchType, PodAssignment, PodName, TableAssignment, TableName, Team},
  },
  modules::{
    game_match::GameMatchRepository, judging_session::JudgingSessionRepository, pod_name::PodRepository,
    schedule::Schedule, table_name::TableRepository, team::TeamRepository,
  },
};

pub struct ScheduleApi;

// Helper function to extract a single value from HashMap, handling errors
fn extract_single<T: Clone>(
  map: HashMap<String, T>,
  identifier: &str,
  entity_type: &str,
) -> std::result::Result<(String, T), Status> {
  if map.is_empty() {
    log::error!("No {} found with identifier: {}", entity_type, identifier);
    return Err(Status::not_found(format!(
      "No {} found with identifier: {}",
      entity_type, identifier
    )));
  }

  if map.len() > 1 {
    log::error!(
      "Multiple {}s found with the same identifier: {}",
      entity_type,
      identifier
    );
    return Err(Status::internal(format!(
      "Multiple {}s found with the same identifier: {}",
      entity_type, identifier
    )));
  }

  map
    .into_iter()
    .next()
    .ok_or_else(|| Status::internal(format!("{} not found", entity_type)))
}

#[tonic::async_trait]
impl ScheduleService for ScheduleApi {
  async fn upload_schedule_csv(
    &self,
    request: Request<UploadScheduleCsvRequest>,
  ) -> Result<Response<UploadScheduleCsvResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let csv_bytes = request.into_inner().csv_data;
    let csv_string = String::from_utf8_lossy(&csv_bytes);

    let schedule = match Schedule::from(&csv_string) {
      Ok(schedule) => schedule,
      Err(e) => return Err(Status::internal(format!("Failed to parse schedule: {}", e))),
    };

    // setup teams
    if let Some(scheduled_teams) = schedule.scheduled_teams {
      log::info!("Adding {} teams...", scheduled_teams.teams.len());
      for team in scheduled_teams.teams {
        let t = Team {
          team_number: team.team_number.clone(),
          name: team.name,
          affiliation: team.affiliation,
        };
        match Team::add(&t) {
          Ok(_) => log::info!("  ✓ Added team {}", team.team_number),
          Err(e) => {
            log::error!("Failed to add team {}: {}", t.team_number, e);
            return Err(Status::internal(format!("Failed to add team: {}", e)));
          }
        }
      }
    }

    // setup tables
    let tables = schedule.table_names;
    log::info!("Adding {} tables...", tables.len());
    for table in tables {
      let t = TableName {
        table_name: table.clone(),
      };
      match TableName::add(&t) {
        Ok(_) => log::info!("  ✓ Added table {}", table),
        Err(e) => {
          log::error!("Failed to add table {}: {}", t.table_name, e);
          return Err(Status::internal(format!("Failed to add table: {}", e)));
        }
      }
    }

    // setup matches
    if let Some(scheduled_matches) = schedule.scheduled_matches {
      log::info!("Adding {} ranking matches...", scheduled_matches.matches.len());
      for game_match in scheduled_matches.matches {
        let mut table_assignments: Vec<TableAssignment> = Vec::new();
        for assignment in game_match.table_assignments {
          let table_map = match TableName::get_by_name(&assignment.table_name) {
            Ok(map) => map,
            Err(e) => {
              log::error!("Database error getting table {}: {}", assignment.table_name, e);
              return Err(Status::internal(format!("Database error: {}", e)));
            }
          };
          let (table_id, _) = extract_single(table_map, &assignment.table_name, "table")?;

          let team_map = match Team::get_by_number(&assignment.team_number) {
            Ok(map) => map,
            Err(e) => {
              log::error!("Database error getting team {}: {}", assignment.team_number, e);
              return Err(Status::internal(format!("Database error: {}", e)));
            }
          };
          let (team_id, _) = extract_single(team_map, &assignment.team_number, "team")?;

          table_assignments.push(TableAssignment {
            table_id,
            team_id,
            score_submitted: false,
          });
        }

        let m = GameMatch {
          match_number: game_match.match_number.clone(),
          start_time: Some(game_match.start_time),
          end_time: Some(game_match.end_time),
          assignments: table_assignments,
          completed: false,
          match_type: MatchType::Ranking.into(),
        };

        match GameMatch::add(&m) {
          Ok(_) => log::info!("  ✓ Added match {}", game_match.match_number),
          Err(e) => {
            log::error!("Failed to add match {}: {}", m.match_number, e);
            return Err(Status::internal(format!("Failed to add match: {}", e)));
          }
        }
      }
    }

    // setup practice matches
    if let Some(scheduled_practice_matches) = schedule.scheduled_practice_matches {
      log::info!(
        "Adding {} practice matches...",
        scheduled_practice_matches.matches.len()
      );
      for game_match in scheduled_practice_matches.matches {
        let mut table_assignments: Vec<TableAssignment> = Vec::new();
        for assignment in game_match.table_assignments {
          let table_map = match TableName::get_by_name(&assignment.table_name) {
            Ok(map) => map,
            Err(e) => {
              log::error!("Database error getting table {}: {}", assignment.table_name, e);
              return Err(Status::internal(format!("Database error: {}", e)));
            }
          };
          let (table_id, _) = extract_single(table_map, &assignment.table_name, "table")?;

          let team_map = match Team::get_by_number(&assignment.team_number) {
            Ok(map) => map,
            Err(e) => {
              log::error!("Database error getting team {}: {}", assignment.team_number, e);
              return Err(Status::internal(format!("Database error: {}", e)));
            }
          };
          let (team_id, _) = extract_single(team_map, &assignment.team_number, "team")?;

          table_assignments.push(TableAssignment {
            table_id,
            team_id,
            score_submitted: false,
          });
        }

        let m = GameMatch {
          match_number: game_match.match_number.clone(),
          start_time: Some(game_match.start_time),
          end_time: Some(game_match.end_time),
          assignments: table_assignments,
          completed: false,
          match_type: MatchType::Practice.into(),
        };

        match GameMatch::add(&m) {
          Ok(_) => log::info!("  ✓ Added practice match {}", game_match.match_number),
          Err(e) => {
            log::error!("Failed to add practice match {}: {}", m.match_number, e);
            return Err(Status::internal(format!("Failed to add practice match: {}", e)));
          }
        }
      }
    }

    // setup pods
    let pods = schedule.pod_names;
    log::info!("Adding {} pods...", pods.len());
    for pod in pods {
      let p = PodName { pod_name: pod.clone() };
      match PodName::add(&p) {
        Ok(_) => log::info!("  ✓ Added pod {}", pod),
        Err(e) => {
          log::error!("Failed to add pod {}: {}", p.pod_name, e);
          return Err(Status::internal(format!("Failed to add pod: {}", e)));
        }
      }
    }

    // setup judging sessions
    if let Some(scheduled_judging) = schedule.scheduled_judging {
      log::info!("Adding {} judging sessions...", scheduled_judging.sessions.len());
      for session in scheduled_judging.sessions {
        let mut pod_assignments: Vec<PodAssignment> = Vec::new();
        for assignment in session.pod_assignments {
          let pod_map = match PodName::get_by_name(&assignment.pod_name) {
            Ok(map) => map,
            Err(e) => {
              log::error!("Database error getting pod {}: {}", assignment.pod_name, e);
              return Err(Status::internal(format!("Database error: {}", e)));
            }
          };
          let (pod_id, _) = extract_single(pod_map, &assignment.pod_name, "pod")?;

          let team_map = match Team::get_by_number(&assignment.team_number) {
            Ok(map) => map,
            Err(e) => {
              log::error!("Database error getting team {}: {}", assignment.team_number, e);
              return Err(Status::internal(format!("Database error: {}", e)));
            }
          };
          let (team_id, _) = extract_single(team_map, &assignment.team_number, "team")?;

          pod_assignments.push(PodAssignment {
            pod_id,
            team_id,
            core_values_submitted: false,
            innovation_submitted: false,
            robot_design_submitted: false,
          });
        }

        let s = JudgingSession {
          session_number: session.session_number.clone(),
          start_time: Some(session.start_time),
          end_time: Some(session.end_time),
          assignments: pod_assignments,
          complete: false,
        };

        match JudgingSession::add(&s) {
          Ok(_) => log::info!("  ✓ Added judging session {}", session.session_number),
          Err(e) => {
            log::error!("Failed to add judging session {}: {}", s.session_number, e);
            return Err(Status::internal(format!("Failed to add judging session: {}", e)));
          }
        }
      }
    }

    log::info!("Schedule upload completed successfully!");
    Ok(Response::new(UploadScheduleCsvResponse {}))
  }
}
