use log::error;
use rocket::{State, get, http::Status};
use tms_utils::{security::Security, security::encrypt, TmsClients, network_schemas::TeamsResponse, schemas::Team, TmsRespond, TmsRouteResponse};

use crate::db::db::TmsDB;

#[get("/teams/get/<uuid>")]
pub fn teams_get_route(_security: &State<Security>, clients: &State<TmsClients>, db: &State<std::sync::Arc<TmsDB>>, uuid: String) -> TmsRouteResponse<()> {
  // get teams from db and put into TeamsResponse
  let mut teams:Vec<Team> = vec![];

  for team_raw in db.tms_data.teams.iter() {
    let team = match team_raw {
      Ok(team) => team.1,
      _ => {
        error!("Failed to get team");
        TmsRespond!(Status::BadRequest, "Failed to get team".to_string());
      }
    };
    
    teams.push(team.clone());
  }

  let teams_response = TeamsResponse {
    teams
  };

  TmsRespond!(
    Status::Ok,
    teams_response,
    clients,
    uuid
  )
}