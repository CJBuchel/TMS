use rocket::{*, http::Status};
use tms_macros::tms_private_route;
use tms_utils::{security::Security, TmsClients, TmsRouteResponse, TmsRespond, TmsRequest, tms_clients_ws_send, network_schemas::SocketMessage};
use crate::db::db::TmsDB;

#[tms_private_route]
#[post("/publish/<uuid>", data = "<message>")]
pub async fn publish_route(message: String) -> TmsRouteResponse<()> {
  let socket_message: SocketMessage = TmsRequest!(message, security);
  tms_clients_ws_send(socket_message.to_owned(), clients.inner().to_owned(), Some(uuid)).await;
  TmsRespond!();
}