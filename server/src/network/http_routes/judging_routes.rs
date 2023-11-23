use log::error;
use rocket::{State, get, http::Status, post};

use tms_macros::tms_private_route;
use tms_utils::{security::Security, security::encrypt, TmsClients, TmsRouteResponse, schemas::{JudgingSession, create_permissions}, TmsRespond, network_schemas::{JudgingSessionsResponse, JudgingSessionRequest, JudgingSessionResponse, JudgingSessionUpdateRequest, SocketMessage, JudgingSessionDeleteRequest, JudgingSessionAddRequest}, TmsRequest, check_permissions, tms_clients_ws_send, with_clients_read};

use crate::db::{db::TmsDB, tree::{UpdateTree, UpdateError}};

#[tms_private_route]
#[get("/judging_sessions/get/<uuid>")]
pub async fn judging_sessions_get_route() -> TmsRouteResponse<()> {
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

  let result = with_clients_read(clients, |client_map| {
    client_map.clone()
  }).await;

  match result {
    Ok(map) => {
      TmsRespond!(
        Status::Ok,
        judging_sessions_response,
        map,
        uuid
      )
    },
    Err(_) => {
      error!("failed to get clients lock");
      TmsRespond!(Status::InternalServerError, "Failed to get clients lock".to_string());
    }
  }
}

#[tms_private_route]
#[post("/judging_session/get/<uuid>", data = "<message>")]
pub async fn judging_session_get_route(message: String) -> TmsRouteResponse<()> {
  let judging_session_request: JudgingSessionRequest = TmsRequest!(message.clone(), security);

  match db.tms_data.judging_sessions.get(&judging_session_request.session_number).unwrap() {
    Some(j) => {
      let judging_session_response: JudgingSessionResponse = JudgingSessionResponse { judging_session: j.clone() };

      let result = with_clients_read(clients, |client_map| {
        client_map.clone()
      }).await;

      match result {
        Ok(map) => {
          TmsRespond!(
            Status::Ok,
            judging_session_response,
            map,
            uuid
          )
        },
        Err(_) => {
          error!("failed to get clients lock");
          TmsRespond!(Status::InternalServerError, "Failed to get clients lock".to_string());
        }
      }
    },
    None => {
      TmsRespond!(Status::NotFound, "Failed to find session".to_string());
    }
  };
}

#[tms_private_route]
#[post("/judging_session/update/<uuid>", data = "<message>")]
pub async fn judging_session_update_route(message: String) -> TmsRouteResponse<()> {
  let message: JudgingSessionUpdateRequest = TmsRequest!(message.clone(), security);

  let mut perms = create_permissions();
  perms.judge_advisor = Some(true);
  perms.judge = Some(true);

  if check_permissions(clients, uuid, message.auth_token, perms).await {
    match db.tms_data.judging_sessions.get(message.session_number.clone()).unwrap() {
      Some(s) => {
        let origin_session_number = s.session_number.clone();
        match db.tms_data.judging_sessions.update(origin_session_number.as_bytes(), message.judging_session.session_number.as_bytes(), message.judging_session.clone()) {
          Ok(_) => {},
          Err(e) => {
            match e {
              UpdateError::KeyExists => {
                error!("Failed to update session, session number already exists");
                TmsRespond!(Status::BadRequest, "Failed to update session, session number already exists".to_string());
              },
              _ => {
                TmsRespond!(Status::BadRequest, "Failed to update session".to_string());
              }
            }
          }
        }

        // send updates to clients
        tms_clients_ws_send(SocketMessage {
          from_id: None,
          topic: String::from("judging_session"),
          sub_topic: String::from("update"),
          message: origin_session_number.clone(),
        }, clients.inner().clone(), None).await;

        // send another update for the new match (if the new match number changed from origin)
        tms_clients_ws_send(SocketMessage {
          from_id: None,
          topic: String::from("judging_session"),
          sub_topic: String::from("update"),
          message: message.judging_session.session_number.clone(),
        }, clients.inner().clone(), None).await;

        TmsRespond!()
      },
      None => {
        TmsRespond!(Status::NotFound, "Failed to find session".to_string());
      }
    }
  }

  TmsRespond!(Status::Unauthorized)
}

#[tms_private_route]
#[post("/judging_session/delete/<uuid>", data = "<message>")]
pub async fn judging_session_delete_route(message: String) -> TmsRouteResponse<()> {
  let message: JudgingSessionDeleteRequest = TmsRequest!(message.clone(), security);

  let mut perms = create_permissions();
  perms.judge_advisor = Some(true);

  if check_permissions(clients, uuid, message.auth_token, perms).await {
    match db.tms_data.judging_sessions.get(message.session_number.clone()).unwrap() {
      Some(_) => {
        let _ = db.tms_data.judging_sessions.remove(message.session_number.as_bytes());

        // send updates to clients
        tms_clients_ws_send(SocketMessage {
          from_id: None,
          topic: String::from("judging_sessions"),
          sub_topic: String::from("update"),
          message: "".to_string(),
        }, clients.inner().clone(), None).await;

        TmsRespond!()
      },
      None => {
        TmsRespond!(Status::NotFound, "Failed to find session".to_string());
      }
    }
  }

  TmsRespond!(Status::Unauthorized)
}


#[tms_private_route]
#[post("/judging_session/add/<uuid>", data = "<message>")]
pub async fn judging_session_add_route(message: String) -> TmsRouteResponse<()> {
  let session_request: JudgingSessionAddRequest = TmsRequest!(message.clone(), security);
  let mut perms = create_permissions();
  perms.judge_advisor = Some(true);

  if check_permissions(clients, uuid, session_request.auth_token, perms).await {
    let session_number = session_request.judging_session.session_number.clone();
    let session = session_request.judging_session.clone();
    let _ = db.tms_data.judging_sessions.insert(session_number.as_bytes(), session.clone());
    // send updates to clients
    tms_clients_ws_send(SocketMessage {
      from_id: None,
      topic: String::from("judging_sessions"),
      sub_topic: String::from("update"),
      message: "".to_string(),
    }, clients.inner().clone(), None).await;
    TmsRespond!()
  }

  TmsRespond!(Status::Unauthorized)
}
