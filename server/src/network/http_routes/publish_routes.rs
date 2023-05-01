use rocket::{*, http::Status};
use tms_utils::{security::Security, TmsClients, TmsRouteResponse, TmsRespond, TmsRequest, tms_client_send_response};


use crate::schemas::*;

#[post("/publish/<uuid>", data = "<message>")]
pub fn publish_route(security: &State<Security>, clients: &State<TmsClients>, uuid: String, message: String) -> TmsRouteResponse<()> {
  let socket_message: SocketMessage = TmsRequest!(message, security);
  tms_client_send_response(socket_message.to_owned(), clients.inner().to_owned(), Some(uuid));
  TmsRespond!();
}