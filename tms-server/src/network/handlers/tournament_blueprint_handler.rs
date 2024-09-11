use crate::database::*;

pub async fn tournament_blueprint_add_blueprint_handler(request: String, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  // we're manually using serde here because we need the bad match error
  // rather than using the data scheme from_json_string
  let tournament_blueprint: TournamentBlueprint = match serde_json::from_str(&request) {
    Ok(tournament_blueprint) => tournament_blueprint,
    Err(e) => {
      log::error!("Failed to parse tournament blueprint: {}", e);
      return Ok(warp::http::StatusCode::BAD_REQUEST);
    }
  };

  let read_db = db.read().await;
  match read_db.insert_blueprint(tournament_blueprint.clone(), None).await {
    Ok(_) => {
      log::info!("Inserted blueprint: {}", tournament_blueprint.title);
      return Ok(warp::http::StatusCode::OK);
    }
    Err(e) => {
      log::error!("Failed to insert blueprint: {}", e);
      return Ok(warp::http::StatusCode::INTERNAL_SERVER_ERROR);
    }
  }
}
