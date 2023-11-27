use log::{error, warn};
use rocket::{State, http::Status, get, post};
use tms_macros::tms_private_route;
use tms_utils::{security::encrypt, TmsClients, TmsRouteResponse, Mission, Games, TmsRespond, network_schemas::{MissionsResponse, QuestionsResponse, GameResponse, SeasonsResponse, QuestionsValidateRequest, QuestionsValidateResponse}, TmsRequest, schemas::create_permissions, check_permissions, with_clients_read};
use tms_utils::security::Security;

use crate::{db::db::TmsDB, event_service::TmsEventServiceArc};


#[get("/missions/get/<uuid>")]
pub async fn missions_get_route(clients: &State<TmsClients>, db: &State<std::sync::Arc<TmsDB>>, uuid: String) -> TmsRouteResponse<()> {
  // get season
  let season = db.get_data().await.event.get().unwrap().unwrap().season;
  let missions = match Games::get_games().get(season.as_str()) {
    Some(g) => g.get_missions(),
    None => Vec::<Mission>::new()
  };

  let result = with_clients_read(clients, |client_map| {
    client_map.clone()
  }).await;

  match result {
    Ok(map) => {
      TmsRespond!(
        Status::Ok,
        MissionsResponse { missions },
        map,
        uuid
      );
    },
    Err(_) => {
      error!("failed to get clients lock");
      TmsRespond!(Status::InternalServerError, "Failed to get clients lock".to_string());
    }
  }
}

#[get("/questions/get/<uuid>")]
pub async fn questions_get_route(clients: &State<TmsClients>, db: &State<std::sync::Arc<TmsDB>>, uuid: String) -> TmsRouteResponse<()> {
  
  // get season
  let season = db.get_data().await.event.get().unwrap().unwrap().season;
  let questions = match Games::get_games().get(season.as_str()) {
    Some(g) => g.get_questions(),
    None => Vec::<tms_utils::Score>::new()
  };

  let result = with_clients_read(clients, |client_map| {
    client_map.clone()
  }).await;

  warn!("Getting seasonal questions: {:?}", season);

  match result {
    Ok(map) => {
      TmsRespond!(
        Status::Ok,
        QuestionsResponse { questions },
        map,
        uuid
      );
    },
    Err(_) => {
      error!("failed to get clients lock");
      TmsRespond!(Status::InternalServerError, "Failed to get clients lock".to_string());
    }
  }
}

#[tms_private_route]
#[post("/questions/validate/<uuid>", data = "<message>")]
pub async fn validate_questions_route(message: String, tms_event_service: &State<TmsEventServiceArc>) -> TmsRouteResponse<()> {
  let message: QuestionsValidateRequest = TmsRequest!(message.clone(), security);

  let mut perms = create_permissions(); // referees/head referee/admin
  perms.head_referee = Some(true);
  perms.referee = Some(true);

  if check_permissions(clients, uuid.clone(), message.auth_token, perms).await {
    // get event from db and check season string

    let result = tms_event_service.read().await.scoring.validate(message.answers).await;

    match result {
      Some(validation) => {
        let result = with_clients_read(clients, |client_map| {
          client_map.clone()
        }).await;

        match result {
          Ok(map) => {
            TmsRespond!(
              Status::Ok,
              QuestionsValidateResponse { errors: validation.errors, score: validation.score },
              map,
              uuid
            );
          },
          Err(_) => {
            TmsRespond!(Status::InternalServerError, "Failed to get clients lock".to_string());
          }
        }
      },
      None => {
        TmsRespond!(Status::NotFound, "Season not found".to_string());
      }
    }
  }

  TmsRespond!(Status::Unauthorized)
}

#[get("/game/get/<uuid>")]
pub async fn game_get_route(clients: &State<TmsClients>, tms_event_service: &State<TmsEventServiceArc>, uuid: String) -> TmsRouteResponse<()> {
  let game = tms_event_service.read().await.scoring.get_game().await;
  let client_map = with_clients_read(clients, |client_map| {
    client_map.clone()
  }).await;


  match client_map {
    Ok(map) => {
      TmsRespond!(
        Status::Ok,
        GameResponse { game },
        map,
        uuid
      );
    },
    Err(_) => {
      warn!("failed to get clients lock");
      TmsRespond!(Status::InternalServerError, "Failed to get clients lock".to_string());
    }
  }
}

#[get("/seasons/get/<uuid>")]
pub async fn seasons_get_route(clients: &State<TmsClients>, uuid: String) -> TmsRouteResponse<()> {
  // get available season
  
  let seasons = Games::get_games().map().keys().map(|k| k.to_string()).collect::<Vec<String>>();

  let result = with_clients_read(clients, |client_map| {
    client_map.clone()
  }).await;

  match result {
    Ok(map) => {
      TmsRespond!(
        Status::Ok,
        SeasonsResponse { seasons },
        map,
        uuid
      );
    },
    Err(_) => {
      TmsRespond!(Status::InternalServerError, "Failed to get clients lock".to_string());
    }
  }
}