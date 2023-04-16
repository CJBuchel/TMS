
use std::net::IpAddr;

use super::{security::{Security}, clients::{Clients}};
use ::log::info;
use rocket::{*, http::Status};

mod register_routes;
use register_routes::*;

mod publish_routes;
use publish_routes::*;

#[get("/pulse")]
fn pulse_route() -> Result<Status, ()> {
  Ok(Status::Accepted)
}

pub struct TmsHttpServer {
  security: Security,
  clients: Clients,
  port: u16,
}

impl TmsHttpServer {
  pub fn new(security: Security, clients: Clients, port: u16) -> Self {
    Self { security, clients, port }
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
      .mount("/requests", routes![
        pulse_route,
        register_route,
        unregister_route,
        publish_route
      ])
  }
}