use rocket::{State, http::Status, get, post};
use tms_macros::tms_private_route;
use tms_utils::{security::encrypt, TmsClients, TmsRouteResponse, Mission, Games, TmsRespond, network_schemas::{MissionsResponse, QuestionsResponse, GameResponse, SeasonsResponse, QuestionsValidateRequest, QuestionsValidateResponse}, TmsRequest, schemas::create_permissions, check_permissions};
use tms_utils::security::Security;

use crate::{db::db::TmsDB, event_service::TmsEventServiceArc};


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
pub async fn validate_questions_route(message: String, tms_event_service: &State<TmsEventServiceArc>) -> TmsRouteResponse<()> {
  let message: QuestionsValidateRequest = TmsRequest!(message.clone(), security);

  let mut perms = create_permissions(); // referees/head referee/admin
  perms.head_referee = Some(true);
  perms.referee = Some(true);

  if check_permissions(clients, uuid.clone(), message.auth_token, perms) {
    // get event from db and check season string
    match tms_event_service.lock().await.scoring.validate(message.answers) {
      Some(validation) => {
        TmsRespond!(
          Status::Ok,
          QuestionsValidateResponse { errors: validation.errors, score: validation.score },
          clients,
          uuid
        )
      },
      None => {
        TmsRespond!(Status::NotFound, "Season not found".to_string());
      }
    };
  }

  TmsRespond!(Status::Unauthorized)
}

#[get("/game/get/<uuid>")]
pub async fn game_get_route(clients: &State<TmsClients>, tms_event_service: &State<TmsEventServiceArc>, uuid: String) -> TmsRouteResponse<()> {
  // get season
  let game = tms_event_service.lock().await.scoring.get_game();

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