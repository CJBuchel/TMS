use rocket::{post, http::Status, State};
use tms_macros::tms_private_route;
use tms_utils::{TmsRouteResponse, TmsRespond, security::Security, TmsClients, network_schemas::{SocketMessage, TimerRequest}, TmsRequest, schemas::create_permissions, check_permissions, tms_clients_ws_send};

use crate::{db::db::TmsDB, event_service::{TmsEventServiceArc, with_tms_event_service_write}};

#[tms_private_route]
#[post("/timer/start/<uuid>", data = "<message>")]
pub async fn start_timer_route(tms_event_service: &State<TmsEventServiceArc>, message: String) -> TmsRouteResponse<()> {
  let message: TimerRequest = TmsRequest!(message.clone(), security);

  let mut perms = create_permissions();
  perms.head_referee = Some(true);
  if check_permissions(clients, uuid, message.auth_token, perms).await {

    // start the timer
    let result = with_tms_event_service_write(tms_event_service, |service| {
      service.match_control.start_timer(true)
    }).await;

    match result {
      Ok(_) => TmsRespond!(),
      Err(_) => TmsRespond!(Status::InternalServerError)
    }
  }
  
  TmsRespond!(Status::Unauthorized)
}

#[tms_private_route]
#[post("/timer/pre_start/<uuid>", data = "<message>")]
pub async fn pre_start_timer_route(tms_event_service: &State<TmsEventServiceArc>, message: String) -> TmsRouteResponse<()> {
  let message: TimerRequest = TmsRequest!(message.clone(), security);

  let mut perms = create_permissions();
  perms.head_referee = Some(true);
  if check_permissions(clients, uuid, message.auth_token, perms).await {
    let result = with_tms_event_service_write(tms_event_service, |service| {
      service.match_control.pre_start_timer()
    }).await;

    match result {
      Ok(_) => TmsRespond!(),
      Err(_) => TmsRespond!(Status::InternalServerError)
    }
  }
  
  TmsRespond!(Status::Unauthorized)
}

#[tms_private_route]
#[post("/timer/stop/<uuid>", data = "<message>")]
pub async fn stop_timer_route(tms_event_service: &State<TmsEventServiceArc>, message: String) -> TmsRouteResponse<()> {
  let message: TimerRequest = TmsRequest!(message.clone(), security);

  let mut perms = create_permissions();
  perms.head_referee = Some(true);
  if check_permissions(clients, uuid, message.auth_token, perms).await {
    // stop the timer

    let result = with_tms_event_service_write(tms_event_service, |service| {
      service.match_control.stop_timer()
    }).await;


    match result {
      Ok(_) => TmsRespond!(),
      Err(_) => TmsRespond!(Status::InternalServerError)
    }
  }
  
  TmsRespond!(Status::Unauthorized)
}

#[tms_private_route]
#[post("/timer/reload/<uuid>", data = "<message>")]
pub async fn reload_timer_route(message: String) -> TmsRouteResponse<()> {
  let message: TimerRequest = TmsRequest!(message.clone(), security);

  let mut perms = create_permissions();
  perms.head_referee = Some(true);
  if check_permissions(clients, uuid, message.auth_token, perms).await {
    // send the reload signal, the displays should handle the rest
    tms_clients_ws_send(SocketMessage {
      from_id: None,
      topic: String::from("clock"),
      sub_topic: String::from("reload"),
      message: String::from("")
    }, clients.inner().clone(), None).await;
    TmsRespond!()
  }
  
  TmsRespond!(Status::Unauthorized)
}