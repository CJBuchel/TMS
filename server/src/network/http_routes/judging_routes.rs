use log::error;
use rocket::{State, get, http::Status};

use tms_utils::{security::Security, security::encrypt, TmsClients, TmsRouteResponse, schemas::JudgingSession, TmsRespond, network_schemas::JudgingSessionsResponse};

use crate::db::db::TmsDB;

#[get("/judging_sessions/get/<uuid>")]
pub fn judging_sessions_get_route(_security: &State<Security>, clients: &State<TmsClients>, db: &State<std::sync::Arc<TmsDB>>, uuid: String) -> TmsRouteResponse<()> {
  // get matches from db and put into MatchesResponse
  let mut judging_sessions:Vec<JudgingSession> = vec![];

  for judging_sessions_raw in db.tms_data.judging_sessions.iter() {
    let judging_session = match judging_sessions_raw {
      Ok(judging_session) => judging_session.1,
      _ => {
        error!("Failed to get judging session");
        TmsRespond!(Status::BadRequest, "Failed to get judging session".to_string());
      }
    };
    
    judging_sessions.push(judging_session.clone());
  }

  let judging_sessions_response = JudgingSessionsResponse {
    judging_sessions
  };

  TmsRespond!(
    Status::Ok,
    judging_sessions_response,
    clients,
    uuid
  )
}