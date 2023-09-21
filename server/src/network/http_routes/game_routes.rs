use rocket::{State, http::Status, get, post};
use tms_macros::tms_private_route;
use tms_utils::{security::encrypt, TmsClients, TmsRouteResponse, Mission, Games, TmsRespond, network_schemas::{MissionsResponse, QuestionsResponse, GameResponse, SeasonsResponse, QuestionsValidateRequest, QuestionsValidateResponse}, TmsRequest, schemas::create_permissions, check_permissions};
use tms_utils::security::Security;

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

#[tms_private_route]
#[post("/questions/validate/<uuid>", data = "<message>")]
pub fn validate_questions_route(message: String) -> TmsRouteResponse<()> {
  let message: QuestionsValidateRequest = TmsRequest!(message.clone(), security);

  let mut perms = create_permissions(); // referees/head referee/admin
  perms.head_referee = Some(true);
  perms.referee = Some(true);

  if check_permissions(clients, uuid.clone(), message.auth_token, perms) {
    // get event from db and check season string
    let season = db.tms_data.event.get().unwrap().unwrap().season;
    match Games::get_games().get(season.as_str()) {
      Some(g) => {
        let errors = g.validate(message.answers.clone());
        let score = g.score(message.answers.clone());
        TmsRespond!(
          Status::Ok,
          QuestionsValidateResponse { errors, score },
          clients,
          uuid
        )
      },
      None => {
        TmsRespond!(Status::BadRequest, "Season not found".to_string());
      }
    };
  }

  TmsRespond!(Status::Unauthorized)
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
      rule_book_url: "".to_string(),
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

#[get("/seasons/get/<uuid>")]
pub fn seasons_get_route(clients: &State<TmsClients>, uuid: String) -> TmsRouteResponse<()> {
  // get available season
  
  let seasons = Games::get_games().map().keys().map(|k| k.to_string()).collect::<Vec<String>>();

  TmsRespond!(
    Status::Ok,
    SeasonsResponse { seasons },
    clients,
    uuid
  )
}