
use log::error;
use rocket::{State, get, http::Status, post};
use tms_macros::tms_private_route;
use tms_utils::{security::Security, security::encrypt, TmsClients, TmsRouteResponse, schemas::{GameMatch, create_permissions}, TmsRespond, network_schemas::{MatchesResponse, MatchRequest, MatchResponse, MatchLoadRequest}, TmsRequest, check_permissions};

use crate::{db::db::TmsDB, event_service::TmsEventService};

#[get("/matches/get/<uuid>")]
pub fn matches_get_route(clients: &State<TmsClients>, db: &State<std::sync::Arc<TmsDB>>, uuid: String) -> TmsRouteResponse<()> {
  // get matches from db and put into MatchesResponse
  let mut matches:Vec<GameMatch> = vec![];

  for match_raw in db.tms_data.matches.iter() {
    let game_match = match match_raw {
      Ok(game_match) => game_match.1,
      _ => {
        error!("Failed to get match");
        TmsRespond!(Status::BadRequest, "Failed to get match".to_string());
      }
    };
    
    matches.push(game_match.clone());
  }

  let matches_response = MatchesResponse {
    matches
  };

  TmsRespond!(
    Status::Ok,
    matches_response,
    clients,
    uuid
  )
}

#[post("/match/get/<uuid>", data = "<message>")]
pub fn match_get_route(security: &State<Security>, clients: &State<TmsClients>, db: &State<std::sync::Arc<TmsDB>>, uuid: String, message: String) -> TmsRouteResponse<()> {
  let match_request: MatchRequest = TmsRequest!(message.clone(), security);

  match db.tms_data.matches.get(&match_request.match_number).unwrap() {
    Some(m) => {
      let match_response: MatchResponse = MatchResponse { game_match: m.clone() };

      TmsRespond!(
        Status::Ok,
        match_response,
        clients,
        uuid
      )
    },
    None => {
      error!("Failed to get match");
      TmsRespond!(Status::BadRequest, "Failed to get match".to_string());
    }
  };
}

#[tms_private_route]
#[post("/match/load/<uuid>", data = "<message>")]
pub fn match_load_route(tms_event_service: &State<std::sync::Arc<std::sync::Mutex<TmsEventService>>>, message: String) -> TmsRouteResponse<()> {
  let message: MatchLoadRequest = TmsRequest!(message.clone(), security);
  let mut perms = create_permissions();
  perms.head_referee = Some(true);
  if check_permissions(clients, uuid, message.auth_token, perms) {
    tms_event_service.lock().unwrap().match_control.load_matches(message.match_numbers);
    TmsRespond!()
  }
  
  TmsRespond!(Status::Unauthorized)
}

#[tms_private_route]
#[post("/match/unload/<uuid>", data = "<message>")]
pub fn match_unload_route(tms_event_service: &State<std::sync::Arc<std::sync::Mutex<TmsEventService>>>, message: String) -> TmsRouteResponse<()> {
  let message: MatchLoadRequest = TmsRequest!(message.clone(), security);
  let mut perms = create_permissions();
  perms.head_referee = Some(true);
  if check_permissions(clients, uuid, message.auth_token, perms) {
    tms_event_service.lock().unwrap().match_control.unload_matches();
    TmsRespond!()
  }
  
  TmsRespond!(Status::Unauthorized)
}