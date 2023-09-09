
use log::error;
use rocket::{State, get, http::Status};
use tms_utils::{security::Security, security::encrypt, TmsClients, TmsRouteResponse, schemas::GameMatch, TmsRespond, network_schemas::MatchesResponse};

use crate::db::db::TmsDB;

#[get("/matches/get/<uuid>")]
pub fn matches_get_route(_security: &State<Security>, clients: &State<TmsClients>, db: &State<std::sync::Arc<TmsDB>>, uuid: String) -> TmsRouteResponse<()> {
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