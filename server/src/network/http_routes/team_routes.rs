use log::{error, warn};
use rocket::{State, get, http::Status, post};
use tms_macros::tms_private_route;
use tms_utils::{security::Security, security::encrypt, TmsClients, network_schemas::{TeamsResponse, TeamRequest, TeamResponse, TeamUpdateRequest, SocketMessage, TeamPostGameScoresheetRequest}, schemas::{Team, create_permissions, rank_teams}, TmsRespond, TmsRouteResponse, TmsRequest, check_permissions, tms_clients_ws_send};

use crate::{db::{db::TmsDB, tree::UpdateTree}, event_service::TmsEventServiceArc};

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
      error!("Failed to get team");
      TmsRespond!(Status::BadRequest, "Failed to get team".to_string());
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
        let _ = db.tms_data.teams.update(origin_team_number.as_bytes(), message.team_number.as_bytes(), message.team_data.clone());
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
        error!("Failed to get team (update) {}", message.team_number);
        TmsRespond!(Status::BadRequest, "Failed to get team".to_string());
      }
    }
  }

  TmsRespond!(Status::Unauthorized)
}

// returns true if success
fn update_rankings(db: &State<std::sync::Arc<TmsDB>>) -> bool {
  let mut teams:Vec<Team> = vec![];

  for team_raw in db.tms_data.teams.iter() {
    let team = match team_raw {
      Ok(team) => team.1,
      _ => {
        error!("Failed to get team (rankings)");
        return false;
      }
    };
    
    teams.push(team.clone());
  }

  let ranked_teams = rank_teams(teams);

  for team in ranked_teams {
    match db.tms_data.teams.update(team.team_number.as_bytes(), team.team_number.as_bytes(), team.clone()) {
      Ok(_) => {},
      Err(_) => {
        error!("Failed to update team {}", team.team_number);
        return false;
      }
    }
  }
  true
}

#[get("/teams/update_ranking")]
pub fn teams_update_ranking_route(db: &State<std::sync::Arc<TmsDB>>, clients: &State<TmsClients>) -> TmsRouteResponse<()> {
  match update_rankings(db) {
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

#[tms_private_route]
#[post("/team/post/game_scoresheet/<uuid>", data = "<message>")]
pub fn team_post_game_scoresheet_route(message: String, tms_event_service: &State<TmsEventServiceArc>) -> TmsRouteResponse<()> {
  let message: TeamPostGameScoresheetRequest = TmsRequest!(message.clone(), security);

  let mut perms = create_permissions();
  perms.head_referee = Some(true);
  perms.referee = Some(true);
  if check_permissions(clients, uuid, message.auth_token, perms) {
    match db.tms_data.teams.get(message.team_number.clone()).unwrap() {
      Some(mut t) => {
        // validate scoresheet, make sure there are no errors and update the score.
        let answers = message.scoresheet.scoresheet.answers.clone();
        match tms_event_service.lock().unwrap().scoring.validate(answers) {
          Some(validation) => {
            if validation.errors.is_empty() {
              let mut scoresheet = message.scoresheet.clone();
              scoresheet.score = validation.score;
              warn!("Scoresheet post {}", scoresheet.score);

              t.game_scores.push(scoresheet.clone());
              // update the team in the database
              let _ = db.tms_data.teams.update(t.team_number.as_bytes(), t.team_number.as_bytes(), t.clone());
      
              // update rankings
              if !update_rankings(db) {
                TmsRespond!(Status::BadRequest, "Failed to update rankings".to_string());
              } else {
      
                // send update to clients (we update all teams because the rankings may have changed)
                tms_clients_ws_send(SocketMessage {
                  from_id: None,
                  topic: String::from("teams"),
                  sub_topic: String::from("update"),
                  message: String::from(""),
                }, clients.inner().clone(), None);
                
                // good response
                TmsRespond!()
              }
            } else {
              error!("Scoresheet validation failed");
              TmsRespond!(Status::BadRequest, "Scoresheet validation failed".to_string());
            }
          },
          None => {
            error!("Failed to get event");
            TmsRespond!(Status::BadRequest, "Failed to get event".to_string());
          }
        }

      },
      None => {
        error!("Failed to get team (scoresheet post) {}", message.team_number);
        TmsRespond!(Status::BadRequest, "Failed to get team".to_string());
      }
    }
  }

  TmsRespond!(Status::Unauthorized)
}