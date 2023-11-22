use log::{error, warn};
use rocket::{State, get, http::Status, post};
use tms_macros::tms_private_route;
use tms_utils::{security::Security, security::encrypt, TmsClients, network_schemas::{TeamsResponse, TeamRequest, TeamResponse, TeamUpdateRequest, SocketMessage, TeamPostGameScoresheetRequest, TeamDeleteRequest, TeamAddRequest}, schemas::{Team, create_permissions, rank_teams}, TmsRespond, TmsRouteResponse, TmsRequest, check_permissions, tms_clients_ws_send};

use crate::{db::{db::TmsDB, tree::{UpdateTree, UpdateError}}, event_service::TmsEventServiceArc};

#[get("/teams/get/<uuid>")]
pub fn teams_get_route(clients: &State<TmsClients>, db: &State<std::sync::Arc<TmsDB>>, uuid: String) -> TmsRouteResponse<()> {
  // get teams from db and put into TeamsResponse
  let mut teams:Vec<Team> = vec![];

  for team_raw in db.tms_data.teams.iter() {
    let team = match team_raw {
      Ok(team) => team.1,
      _ => {
        error!("Failed to get team");
        TmsRespond!(Status::BadRequest, "Failed to get team".to_string());
      }
    };
    
    teams.push(team.clone());
  }

  let teams_response = TeamsResponse {
    teams
  };

  TmsRespond!(
    Status::Ok,
    teams_response,
    clients,
    uuid
  )
}

#[post("/team/get/<uuid>", data = "<message>")]
pub fn team_get_route(security: &State<Security>, clients: &State<TmsClients>, db: &State<std::sync::Arc<TmsDB>>, uuid: String, message: String) -> TmsRouteResponse<()> {
  let team_request: TeamRequest = TmsRequest!(message.clone(), security);

  match db.tms_data.teams.get(&team_request.team_number).unwrap() {
    Some(t) => {
      let team_response: TeamResponse = TeamResponse { team: t.clone() };

      TmsRespond!(
        Status::Ok,
        team_response,
        clients,
        uuid
      )
    },
    None => {
      TmsRespond!(Status::NotFound, "Failed to find team".to_string());
    }
  };
}

#[tms_private_route]
#[post("/team/update/<uuid>", data = "<message>")]
pub fn team_update_route(message: String) -> TmsRouteResponse<()> {
  let message: TeamUpdateRequest = TmsRequest!(message.clone(), security);

  let mut perms = create_permissions();
  perms.head_referee = Some(true);
  perms.judge_advisor = Some(true);
  if check_permissions(clients, uuid, message.auth_token, perms) {
    match db.tms_data.teams.get(message.team_number.clone()).unwrap() {
      Some(t) => {
        let origin_team_number = t.team_number.clone();
        // update db
        match db.tms_data.teams.update(origin_team_number.as_bytes(), message.team_data.team_number.as_bytes(), message.team_data.clone()) {
          Ok(_) => {},
          Err(e) => {
            match e {
              UpdateError::KeyExists => {
                TmsRespond!(Status::Conflict, "Team number already exists".to_string());
              },
              _ => {
                error!("Failed to update team");
                TmsRespond!(Status::BadRequest, "Failed to update team".to_string());
              }
            }
          }
        }


        // update rankings
        if !update_rankings(db, clients) {
          TmsRespond!(Status::BadRequest, "Failed to update rankings".to_string());
        }
        // send updates to clients
        tms_clients_ws_send(SocketMessage {
          from_id: None,
          topic: String::from("team"),
          sub_topic: String::from("update"),
          message: origin_team_number.clone(),
        }, clients.inner().to_owned(), None);

        // send another update for the new team (if the new team number changed from origin)
        tms_clients_ws_send(SocketMessage {
          from_id: None,
          topic: String::from("team"),
          sub_topic: String::from("update"),
          message: message.team_data.team_number.clone(),
        }, clients.inner().to_owned(), None);
        TmsRespond!();

      },
      None => {
        TmsRespond!(Status::NotFound, "Failed to find".to_string());
      }
    }
  }

  TmsRespond!(Status::Unauthorized)
}

#[tms_private_route]
#[post("/team/add/<uuid>", data = "<message>")]
pub fn team_add_route(message: String) -> TmsRouteResponse<()> {
  let message: TeamAddRequest = TmsRequest!(message.clone(), security);

  let mut perms = create_permissions();
  perms.judge_advisor = Some(true);

  if check_permissions(clients, uuid, message.auth_token, perms) {
    match db.tms_data.teams.get(message.team_number.clone()).unwrap() {
      Some(_) => {
        TmsRespond!(Status::Conflict, "Team already exists".to_string());
      },

      None => {
        let team = Team {
          team_number: message.team_number.clone(),
          team_name: message.team_name.clone(),
          team_affiliation: message.team_affiliation.clone(),

          team_id: String::from(""),
          game_scores: vec![],
          core_values_scores: vec![],
          innovation_project_scores: vec![],
          robot_design_scores: vec![],
          ranking: 0
        };


        // add team to db
        match db.tms_data.teams.insert(message.team_number.clone().as_bytes(), team) {
          Ok(_) => {
            // update rankings
            if !update_rankings(db, clients) {
              TmsRespond!(Status::BadRequest, "Failed to update rankings".to_string());
            }
            // send updates to clients
            tms_clients_ws_send(SocketMessage {
              from_id: None,
              topic: String::from("teams"),
              sub_topic: String::from("update"),
              message: "".to_string(),
            }, clients.inner().to_owned(), None);

            tms_clients_ws_send(SocketMessage {
              from_id: None,
              topic: String::from("matches"),
              sub_topic: String::from("update"),
              message: "".to_string(),
            }, clients.inner().to_owned(), None);

            tms_clients_ws_send(SocketMessage {
              from_id: None,
              topic: String::from("judging_sessions"),
              sub_topic: String::from("update"),
              message: "".to_string(),
            }, clients.inner().to_owned(), None);

            // good response
            TmsRespond!();
          },
          Err(_) => {
            error!("Failed to add team");
            TmsRespond!(Status::BadRequest, "Failed to add team".to_string());
          }
        }
      }
    } 
  }

  TmsRespond!(Status::Unauthorized)
}

// returns true if success
fn update_rankings(db: &State<std::sync::Arc<TmsDB>>, clients: &State<TmsClients>) -> bool {
  let mut teams:Vec<Team> = vec![];

  for team_raw in db.tms_data.teams.iter() {
    let team = match team_raw {
      Ok(team) => team.1,
      _ => {
        error!("Failed to update team (rankings)");
        return false;
      }
    };
    
    teams.push(team.clone());
  }

  let ranked_teams = rank_teams(teams.clone());

  // check if there was a ranking update between teams and ranked_teams
  for team in ranked_teams {
    for old_team in teams.clone() {
      if old_team.team_number == team.team_number {
        if old_team.ranking != team.ranking {
          // update the team in the database
          match db.tms_data.teams.update(team.team_number.as_bytes(), team.team_number.as_bytes(), team.clone()) {
            Ok(_) => {
              // update clients about raking change
              tms_clients_ws_send(SocketMessage {
                from_id: None,
                topic: String::from("teams"),
                sub_topic: String::from("update"),
                message: String::from(""),
              }, clients.inner().clone(), None);
            },
            Err(_) => {
              error!("Failed to update team {}", team.team_number);
              return false;
            }
          }
        }
      }
    }
  }
  true
}

#[get("/teams/update_ranking")]
pub fn teams_update_ranking_route(db: &State<std::sync::Arc<TmsDB>>, clients: &State<TmsClients>) -> TmsRouteResponse<()> {
  match update_rankings(db, clients) {
    true => {
      // send update to clients
      tms_clients_ws_send(SocketMessage {
        from_id: None,
        topic: String::from("teams"),
        sub_topic: String::from("update"),
        message: String::from(""),
      }, clients.inner().clone(), None);
      TmsRespond!(Status::Ok)
    },
    false => TmsRespond!(Status::BadRequest, "Failed to update rankings".to_string())
  }
}

fn scoresheet_update_match(res: TeamPostGameScoresheetRequest, db: &State<std::sync::Arc<TmsDB>>, clients: &State<TmsClients>) -> bool {
  match res.match_number {
    Some(m) => {
      match res.table {
        Some(tb) => {
          // update match
          match db.tms_data.matches.get(m.clone()).unwrap() {
            Some(game_match) => {
              let mut updated_match = game_match.clone();
              for on_table in &mut updated_match.match_tables {
                if on_table.table == tb {
                  // update the match
                  on_table.score_submitted = true;

                  // update the match in the database
                  match db.tms_data.matches.update(m.as_bytes(), m.as_bytes(), updated_match.clone()) {
                    Ok(_) => {
                      // send updates to clients
                      tms_clients_ws_send(SocketMessage {
                        from_id: None,
                        topic: String::from("match"),
                        sub_topic: String::from("update"),
                        message: m.clone(),
                      }, clients.inner().clone(), None);
                    },
                    Err(_) => {
                      error!("Failed to update match {}", m);
                      return false;
                    }
                  }
                  return true;
                }
              }
            },
            None => {},
          }
        },
        None => {},
      }
    },
    None => {},
  }

  false
}

#[tms_private_route]
#[post("/team/post/game_scoresheet/<uuid>", data = "<message>")]
pub async fn team_post_game_scoresheet_route(message: String, tms_event_service: &State<TmsEventServiceArc>) -> TmsRouteResponse<()> {
  let message: TeamPostGameScoresheetRequest = TmsRequest!(message.clone(), security);

  let mut perms = create_permissions();
  perms.head_referee = Some(true);
  perms.referee = Some(true);
  if check_permissions(clients, uuid, message.auth_token.clone(), perms) {
    warn!("Scoresheet post request: {}, {}, {}", message.scoresheet.referee, message.team_number.clone(), message.scoresheet.score);
    match db.tms_data.teams.get(message.team_number.clone()).unwrap() {
      Some(mut t) => {
        // validate scoresheet, make sure there are no errors and update the score.
        let answers = message.scoresheet.scoresheet.answers.clone();
        match tms_event_service.lock().await.scoring.validate(answers) {
          Some(validation) => {
            if validation.errors.is_empty() {
              let mut scoresheet = message.scoresheet.clone();
              scoresheet.score = validation.score;
              scoresheet.time_stamp = std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_secs();

              t.game_scores.push(scoresheet.clone());
              // update the team in the database
              let _ = db.tms_data.teams.update(t.team_number.as_bytes(), t.team_number.as_bytes(), t.clone());

              // check if we need to update the match too
              if message.update_match {
                // update match
                if !scoresheet_update_match(message.clone(), db, clients) {
                  error!("Failed to update match");
                  TmsRespond!(Status::BadRequest, "Failed to update match".to_string());
                }
              }
      
              // update rankings
              if !update_rankings(db, clients) {
                TmsRespond!(Status::BadRequest, "Failed to update rankings".to_string());
              } else {
                // send updates to clients
                tms_clients_ws_send(SocketMessage {
                  from_id: None,
                  topic: String::from("team"),
                  sub_topic: String::from("update"),
                  message: t.team_number.clone(),
                }, clients.inner().to_owned(), None);
                
                // good response
                TmsRespond!()
              }
            } else {
              error!("Scoresheet validation failed");
              TmsRespond!(Status::BadRequest, "Scoresheet validation failed".to_string());
            }
          },
          None => {
            TmsRespond!(Status::NotFound, "Failed to find team".to_string());
          }
        }

      },
      None => {
        TmsRespond!(Status::NotFound, "Failed to find team".to_string());
      }
    }
  }

  TmsRespond!(Status::Unauthorized)
}

#[tms_private_route]
#[post("/team/delete/<uuid>", data = "<message>")]
pub async fn team_delete_route(message: String, tms_event_service: &State<TmsEventServiceArc>) -> TmsRouteResponse<()> {
  let message: TeamDeleteRequest = TmsRequest!(message.clone(), security);

  let mut perms = create_permissions();
  perms.judge_advisor = Some(true);
  if check_permissions(clients, uuid, message.auth_token, perms) {

    match db.tms_data.teams.get(message.team_number.clone()).unwrap() {
      Some(t) => {
        match tms_event_service.lock().await.teams.remove_team(t.team_number.clone()) {
          Ok(_) => {
            // update rankings
            if !update_rankings(db, clients) {
              TmsRespond!(Status::BadRequest, "Failed to update rankings".to_string());
            }
            // send updates to clients
            tms_clients_ws_send(SocketMessage {
              from_id: None,
              topic: String::from("teams"),
              sub_topic: String::from("update"),
              message: "".to_string(),
            }, clients.inner().to_owned(), None);

            tms_clients_ws_send(SocketMessage {
              from_id: None,
              topic: String::from("matches"),
              sub_topic: String::from("update"),
              message: "".to_string(),
            }, clients.inner().to_owned(), None);

            tms_clients_ws_send(SocketMessage {
              from_id: None,
              topic: String::from("judging_sessions"),
              sub_topic: String::from("update"),
              message: "".to_string(),
            }, clients.inner().to_owned(), None);

            // good response
            TmsRespond!();
          },
          Err(_) => {
            error!("Failed to remove team from matches, will continue removal...");
            TmsRespond!(Status::BadRequest, "Failed to remove team from matches".to_string());
          }
        }
      },
      None => {
        TmsRespond!(Status::NotFound, "Failed to find team".to_string());
      }
    }
  }

  TmsRespond!(Status::Unauthorized)
}