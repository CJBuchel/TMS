use rocket::{State, http::Status, get};
use tms_utils::{security::encrypt, TmsClients, TmsRouteResponse, Mission, Games, TmsRespond, network_schemas::{MissionsResponse, QuestionsResponse, GameResponse}};

use crate::db::db::TmsDB;


#[get("/missions/get/<uuid>")]
pub fn missions_get_route(clients: &State<TmsClients>, db: &State<std::sync::Arc<TmsDB>>, uuid: String) -> TmsRouteResponse<()> {
  // get season
  let season = db.tms_data.event.get().unwrap().unwrap().season;
  let missions = match Games::get_games().get(season.as_str()) {
    Some(g) => g.get_missions(),
    None => Vec::<Mission>::new()
  };

  TmsRespond!(
    Status::Ok,
    MissionsResponse { missions },
    clients,
    uuid
  )
}

#[get("/questions/get/<uuid>")]
pub fn questions_get_route(clients: &State<TmsClients>, db: &State<std::sync::Arc<TmsDB>>, uuid: String) -> TmsRouteResponse<()> {
  
  // get season
  let season = db.tms_data.event.get().unwrap().unwrap().season;
  let questions = match Games::get_games().get(season.as_str()) {
    Some(g) => g.get_questions(),
    None => Vec::<tms_utils::Score>::new()
  };

  TmsRespond!(
    Status::Ok,
    QuestionsResponse { questions },
    clients,
    uuid
  )
}

#[get("/game/get/<uuid>")]
pub fn game_get_route(clients: &State<TmsClients>, db: &State<std::sync::Arc<TmsDB>>, uuid: String) -> TmsRouteResponse<()> {
  // get season
  let season = db.tms_data.event.get().unwrap().unwrap().season;
  let game = match Games::get_games().get(season.as_str()) {
    Some(g) => g.get_game(),
    None => tms_utils::Game {
      name: "".to_string(),
      program: "".to_string(),
      missions: vec![],
      questions: vec![],
    }
  };

  TmsRespond!(
    Status::Ok,
    GameResponse { game },
    clients,
    uuid
  )
}