
use rocket::{post, http::Status, State};
use tms_macros::tms_private_route;
use tms_utils::{TmsRouteResponse, TmsRespond, security::Security, TmsClients, network_schemas::StartTimerRequest, TmsRequest, schemas::{Permissions, create_permissions}, check_permissions};

use crate::db::db::TmsDB;

#[tms_private_route]
#[post("/timer/start/<uuid>", data = "<message>")]
pub fn start_timer_route(message: String) -> TmsRouteResponse<()> {
  let message: StartTimerRequest = TmsRequest!(message.clone(), security);

  let mut perms = create_permissions();
  perms.head_referee = Some(true);
  if check_permissions(clients, uuid, message.auth_token, perms) {
    // @TODO start timer
    TmsRespond!()
  }
  
  TmsRespond!(Status::Unauthorized)
}