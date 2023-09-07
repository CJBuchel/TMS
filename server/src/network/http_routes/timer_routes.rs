use rocket::{post, http::Status, State};
use tms_macros::tms_private_route;
use tms_utils::{TmsRouteResponse, TmsRespond, security::Security, TmsClients, network_schemas::StartTimerRequest, TmsRequest, schemas::{create_permissions}, check_permissions};

use crate::{db::db::TmsDB, event_service::TmsEventService};

#[tms_private_route]
#[post("/timer/start/<uuid>", data = "<message>")]
pub fn start_timer_route(tms_event_service: &State<std::sync::Arc<std::sync::Mutex<TmsEventService>>>, message: String) -> TmsRouteResponse<()> {
  let message: StartTimerRequest = TmsRequest!(message.clone(), security);

  let mut perms = create_permissions();
  perms.head_referee = Some(true);
  if check_permissions(clients, uuid, message.auth_token, perms) {
    tms_event_service.lock().unwrap().match_control.start_timer();
    TmsRespond!()
  }
  
  TmsRespond!(Status::Unauthorized)
}

// @TODO: pre-start timer