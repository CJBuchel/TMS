use log::{error, warn};
use rocket::{State, get, http::Status, post};
use tms_macros::tms_private_route;
use tms_utils::{security::Security, security::encrypt, TmsClients, network_schemas::{TeamsResponse, TeamRequest, TeamResponse, TeamUpdateRequest, SocketMessage, TeamPostGameScoresheetRequest}, schemas::{Team, create_permissions}, TmsRespond, TmsRouteResponse, TmsRequest, check_permissions, tms_clients_ws_send};

use crate::db::db::TmsDB;

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
        let _ = db.tms_data.teams.insert(origin_team_number.as_bytes(), message.team_data.clone());
        // send updates to clients
        tms_clients_ws_send(SocketMessage {
          from_id: None,
          topic: String::from("teams"),
          sub_topic: String::from("update"),
          message: origin_team_number.clone(),
        }, clients.inner().to_owned(), None);

        // send another update for the new team (if the new team number changed from origin)
        tms_clients_ws_send(SocketMessage {
          from_id: None,
          topic: String::from("teams"),
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

#[tms_private_route]
#[post("/team/post/game_scoresheet/<uuid>", data = "<message>")]
pub fn team_post_game_scoresheet_route(message: String) -> TmsRouteResponse<()> {
  let message: TeamPostGameScoresheetRequest = TmsRequest!(message.clone(), security);

  let mut perms = create_permissions();
  perms.head_referee = Some(true);
  perms.referee = Some(true);
  if check_permissions(clients, uuid, message.auth_token, perms) {
    match db.tms_data.teams.get(message.team_number.clone()).unwrap() {
      Some(mut t) => {
        warn!("Scoresheet post {}", message.scoresheet.score);
        t.game_scores.push(message.scoresheet.clone());

        // update the team in the database
        let _ = db.tms_data.teams.insert(t.team_number.as_bytes(), t.clone());

        // send update to clients
        tms_clients_ws_send(SocketMessage {
          from_id: None,
          topic: String::from("team"),
          sub_topic: String::from("update"),
          message: t.team_number.clone(),
        }, clients.inner().clone(), None);

        TmsRespond!()
      },
      None => {
        error!("Failed to get team (scoresheet post) {}", message.team_number);
        TmsRespond!(Status::BadRequest, "Failed to get team".to_string());
      }
    }
  }

  TmsRespond!(Status::Unauthorized)
}