use ::log::info;
use rocket::{*, http::{Status, Header}, fairing::{Fairing, Info, Kind}, serde::json::Json};

use crate::schemas::*;

mod register_routes;
use register_routes::*;

mod publish_routes;
use publish_routes::*;
use tms_utils::{security::Security, TmsRespond, TmsRouteResponse, TmsClients, TmsRequest};

pub struct CORS;

#[rocket::async_trait]
impl Fairing for CORS {
  fn info(&self) -> Info {
    Info {
      name: "Add CORS headers to responses",
      kind: Kind::Response
    }
  }

  async fn on_response<'r>(&self, _request: &'r Request<'_>, response: &mut Response<'r>) {
    response.set_header(Header::new("Access-Control-Allow-Origin", "*"));
    response.set_header(Header::new("Access-Control-Allow-Methods", "POST, GET, PUT, DELETE"));
    response.set_header(Header::new("Access-Control-Allow-Headers", "*"));
    response.set_header(Header::new("Access-Control-Allow-Credentials", "true"));
  }
}

#[get("/pulse")]
fn pulse_route() -> TmsRouteResponse<(),()> {
  TmsRespond!();
}

#[get("/pulse_integrity", data = "<message>")]
fn pulse_integrity_route(security: &State<Security>, _clients: &State<TmsClients>, message: String) -> TmsRouteResponse<IntegrityMessage, ()> {
  TmsRespond!(Status::Ok, TmsRequest!(message, security));
}


pub struct TmsHttpServer {
  security: Security,
  clients: TmsClients,
  port: u16,
  ws_port: u16,
}

impl TmsHttpServer {
  pub fn new(security: Security, clients: TmsClients, port: u16, ws_port: u16) -> Self {
    Self { security, clients, port, ws_port }
  }

  pub async fn start(&self) -> Rocket<Build> {
    info!("Http Server started");
    let figment = rocket::Config::figment()
      .merge(("port", self.port))
      .merge(("address", "0.0.0.0"));

    rocket::custom(figment)
      .manage(self.clients.clone())
      .manage(self.security.clone())
      .manage(self.security.public_key.clone())
      .manage(self.ws_port.clone())
      .mount("/requests", routes![
        pulse_route,
        pulse_integrity_route,
        register_route,
        unregister_route,
        publish_route
      ]).attach(CORS)
  }
}