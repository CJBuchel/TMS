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
  let result = tms_event_service.read().await.scoring.validate(m.answers).await;



  match result {
    Some(v) => {
      let res = QuestionsValidateResponse { errors: v.errors, score: v.score };
      let socket_message = SocketMessage {
        from_id: None,
        topic: "validation".to_string(),
        sub_topic: "".to_string(),
        message: serde_json::to_string(&res).unwrap(),
      };
      
      tms_client_ws_send(socket_message, clients, target_id, None).await;
    },
    None => {},
  }
}