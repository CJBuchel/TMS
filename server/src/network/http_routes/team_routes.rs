use log::error;
use rocket::{State, get, http::Status, post};
use tms_utils::{security::Security, security::encrypt, TmsClients, network_schemas::{TeamsResponse, TeamRequest, TeamResponse}, schemas::Team, TmsRespond, TmsRouteResponse, TmsRequest};

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

#[post("/team/get/<uuid>", data = "<message>")]
pub fn team_get_route(security: &State<Security>, clients: &State<TmsClients>, db: &State<std::sync::Arc<TmsDB>>, uuid: String, message: String) -> TmsRouteResponse<()> {
  let team_request: TeamRequest = TmsRequest!(message.clone(), security);

  match db.tms_data.teams.get(&team_request.team_number).unwrap() {
    Some(t) => {
      let team_response: TeamResponse = TeamResponse { team: t.clone() };

      TmsRespond!(
        Status::Ok,
        team_response,
        clients,
        uuid
      )
    },
    None => {
      error!("Failed to get team");
      TmsRespond!(Status::BadRequest, "Failed to get team".to_string());
    }
  };
}