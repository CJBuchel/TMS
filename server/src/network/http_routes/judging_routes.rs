use log::error;
use rocket::{State, get, http::Status, post};

use tms_utils::{security::Security, security::encrypt, TmsClients, TmsRouteResponse, schemas::JudgingSession, TmsRespond, network_schemas::{JudgingSessionsResponse, JudgingSessionRequest, JudgingSessionResponse}, TmsRequest};

use crate::db::db::TmsDB;

#[get("/judging_sessions/get/<uuid>")]
pub fn judging_sessions_get_route(clients: &State<TmsClients>, db: &State<std::sync::Arc<TmsDB>>, uuid: String) -> TmsRouteResponse<()> {
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

#[post("/judging_session/get/<uuid>", data = "<message>")]
pub fn judging_session_get_route(security: &State<Security>, clients: &State<TmsClients>, db: &State<std::sync::Arc<TmsDB>>, uuid: String, message: String) -> TmsRouteResponse<()> {
  let judging_session_request: JudgingSessionRequest = TmsRequest!(message.clone(), security);

  match db.tms_data.judging_sessions.get(&judging_session_request.session_number).unwrap() {
    Some(j) => {
      let judging_session_response: JudgingSessionResponse = JudgingSessionResponse { judging_session: j.clone() };

      TmsRespond!(
        Status::Ok,
        judging_session_response,
        clients,
        uuid
      )
    },
    None => {
      error!("Failed to get judging session");
      TmsRespond!(Status::BadRequest, "Failed to get judging session".to_string());
    }
  };
}