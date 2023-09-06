use rocket::{State, post, http::Status};
use tms_macros::tms_private_route;
use tms_utils::{TmsRouteResponse, TmsRespond, security::Security, TmsClients, TmsRequest, schemas::create_permissions, check_permissions, network_schemas::SetupRequest};

use crate::{db::db::TmsDB, event_service::TmsEventService};


#[tms_private_route]
#[post("/setup/<uuid>", data = "<message>")]
pub fn setup_router(tms_event_service: &State<std::sync::Arc<std::sync::Mutex<TmsEventService>>>, message: String) -> TmsRouteResponse<()> {
  let message: SetupRequest = TmsRequest!(message.clone(), security);

  let mut perms = create_permissions();
  perms.admin = true;
  if check_permissions(clients, uuid, message.auth_token, perms) {
    
    TmsRespond!()
  }
  
  TmsRespond!(Status::Unauthorized)
}