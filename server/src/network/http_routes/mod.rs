use std::path::PathBuf;

use ::log::{info};
use rocket::{*, http::{Status, Header}, fairing::{Fairing, Info, Kind}, data::{Limits, ToByteUnit}};

mod register_routes;
use register_routes::*;

mod publish_routes;
use publish_routes::*;

mod user_routes;
use user_routes::*;

mod timer_routes;
use timer_routes::*;

mod event_routes;
use event_routes::*;

mod team_routes;
use team_routes::*;

mod match_routes;
use match_routes::*;

mod judging_routes;
use judging_routes::*;

use tms_utils::{security::Security, security::encrypt, TmsRespond, TmsRouteResponse, TmsClients, TmsRequest, network_schemas::IntegrityMessage, with_clients_write};
use uuid::Uuid;

use crate::{db::db::TmsDB, event_service::TmsEventService};

// CORS fairing
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

// Client timestamp update fairing
pub struct ClientTimestampUpdate;
#[rocket::async_trait]
impl Fairing for ClientTimestampUpdate {
  fn info(&self) -> Info {
    Info {
      name: "Update client timestamp",
      kind: Kind::Request
    }
  }

  async fn on_request(&self, request: &mut Request<'_>, _: &mut Data<'_>) {
    let path_segments: Vec<String> = request.uri().path().split('/').map(|s| s.to_string()).collect();
    // Assuming that UUID is always the last segment
    if let Some(uuid) = path_segments.last() {
      if Uuid::parse_str(uuid).is_ok() { // check if it is a valid uuid
        if let Some(state) = request.rocket().state::<TmsClients>() {
          with_clients_write(&state, |client_map| {
            if let Some(client) = client_map.get_mut(uuid) {
              client.last_timestamp = std::time::SystemTime::now();
            }
    
            // Check all clients for stale connections
            let current_time = std::time::SystemTime::now();
            let mut stale_clients: Vec<String> = Vec::new();
            for (id, client) in client_map.iter() {
              if let Ok(duration) = current_time.duration_since(client.last_timestamp) {
                if duration.as_secs() > (5 * 60) { // 5 mins
                  stale_clients.push(id.to_string());
                }
              }
            }
    
            // remove oldest stale clients if there are more than 100
            let num_allowed_stale_clients = 100;
            if stale_clients.len() > num_allowed_stale_clients {
              stale_clients.sort_by(|a, b| {
                client_map[a].last_timestamp.cmp(&client_map[b].last_timestamp)
              });
    
              for i in 0..(stale_clients.len() - num_allowed_stale_clients) {
                let id = stale_clients[i].clone();
                client_map.remove(&id);
              }
            }
          }).unwrap();
  
        }
      }
    }
  }
}

#[get("/pulse")]
fn pulse_route() -> TmsRouteResponse<()> {
  TmsRespond!();
}

#[post("/pulse_integrity/<uuid>", data = "<message>")]
fn pulse_integrity_route(security: &State<Security>, clients: &State<TmsClients>, uuid: String, message: String) -> TmsRouteResponse<()> {
  let message: IntegrityMessage = TmsRequest!(message, security);
  TmsRespond!(Status::Ok, message, clients.inner(), uuid);
}

#[options("/<_path..>")]
fn cors_preflight(_path: PathBuf) -> Status {
  Status::NoContent
}

pub struct TmsHttpServer {
  tms_event_service: std::sync::Arc<std::sync::Mutex<TmsEventService>>,
  tms_db: std::sync::Arc<TmsDB>,
  security: Security,
  clients: TmsClients,
  port: u16,
  ws_port: u16,
}

impl TmsHttpServer {
  pub fn new(tms_event_service: std::sync::Arc<std::sync::Mutex<TmsEventService>>, tms_db: std::sync::Arc<TmsDB>, security: Security, clients: TmsClients, port: u16, ws_port: u16) -> Self {
    Self { tms_event_service, tms_db, security, clients, port, ws_port }
  }

  pub async fn start(&self) -> Rocket<Build> {
    info!("Http Server started");

    let limits = Limits::default()
      .limit("string", ToByteUnit::megabytes(1));

    let figment = rocket::Config::figment()
      .merge(("port", self.port))
      .merge(("address", "0.0.0.0"))
      .merge(("limits", limits));

    rocket::custom(figment)
      .manage(self.tms_event_service.clone())
      .manage(self.tms_db.clone())
      .manage(self.clients.clone())
      .manage(self.security.clone())
      .manage(self.security.public_key.clone())
      .manage(self.ws_port.clone())
      .mount("/requests", routes![
        // generic routes
        pulse_route,
        pulse_integrity_route,
        register_route,
        unregister_route,
        publish_route,
        login_route,

        // setup routes
        event_setup_route,
        event_purge_route,

        // main data routes
        event_get_route,
        teams_get_route,
        team_get_route,
        matches_get_route,
        match_get_route,
        match_update_route,
        judging_sessions_get_route,
        judging_session_get_route,

        // timer control routes
        start_timer_route,
        pre_start_timer_route,
        stop_timer_route,
        reload_timer_route,
        
        // match control routes
        match_load_route,
        match_unload_route,

        // preflight catcher
        cors_preflight
      ])
      .attach(CORS)
      .attach(ClientTimestampUpdate)
  }
}