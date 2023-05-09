use ::log::info;
use rocket::{*, http::{Status, Header}, fairing::{Fairing, Info, Kind}};

mod register_routes;
use register_routes::*;

mod publish_routes;
use publish_routes::*;

use tms_utils::{security::Security, security::encrypt, TmsRespond, TmsRouteResponse, TmsClients, TmsRequest, schemas::IntegrityMessage};

use crate::db::db::TmsDB;

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
fn pulse_route() -> TmsRouteResponse<()> {
  TmsRespond!();
}

#[post("/pulse_integrity/<uuid>", data = "<message>")]
fn pulse_integrity_route(security: &State<Security>, _clients: &State<TmsClients>, uuid: String, message: String) -> TmsRouteResponse<()> {
  let message: IntegrityMessage = TmsRequest!(message, security);
  TmsRespond!(Status::Ok, message, _clients.inner(), uuid);
}

pub struct TmsHttpServer {
  tms_db: TmsDB,
  security: Security,
  clients: TmsClients,
  port: u16,
  ws_port: u16,
}

impl TmsHttpServer {
  pub fn new(tms_db: TmsDB, security: Security, clients: TmsClients, port: u16, ws_port: u16) -> Self {
    Self { tms_db, security, clients, port, ws_port }
  }

  pub async fn start(&self) -> Rocket<Build> {
    info!("Http Server started");
    let figment = rocket::Config::figment()
      .merge(("port", self.port))
      .merge(("address", "0.0.0.0"));

    rocket::custom(figment)
      .manage(self.tms_db.clone())
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