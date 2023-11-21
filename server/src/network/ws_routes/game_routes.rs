use log::warn;
use tms_utils::{TmsClients, network_schemas::{QuestionsValidateRequest, QuestionsValidateResponse, SocketMessage}, tms_client_ws_send, TmsSocketRequest};

use crate::event_service::TmsEventServiceArc;


pub async fn validate_questions_route(
  message: String, 
  tms_event_service: TmsEventServiceArc,
  clients: TmsClients,
  target_id: String,
) {
  // get the message in it's struct form
  let m: QuestionsValidateRequest = match TmsSocketRequest!(message.clone()) {
    Ok(v) => v,
    Err(_) => {
      warn!("invalid validation message received from: {}", target_id);
      return;
    }
  };

  // validate the answers and send the response
  match tms_event_service.lock() {
    Ok(v) => {
      let event_service = v;
      match event_service.scoring.validate(m.answers) {
        Some(v) => {
          let res = QuestionsValidateResponse { errors: v.errors, score: v.score };
          let socket_message = SocketMessage {
            from_id: None,
            topic: "validation".to_string(),
            sub_topic: "".to_string(),
            message: serde_json::to_string(&res).unwrap(),
          };
        
          tms_client_ws_send(socket_message, clients, target_id, None);
        },
        None => {},
      }
    },
    Err(_) => {},
  }

}