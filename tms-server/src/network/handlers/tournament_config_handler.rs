use crate::database::*;


pub async fn tournament_config_set_name_handler(request: TournamentConfigSetNameRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let mut write_db = db.write().await;
  log::info!("Setting tournament name to: {}", request.name);
  write_db.set_tournament_name(request.name).await;
  Ok(warp::http::StatusCode::OK)
}

pub async fn tournament_config_get_name_handler(db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;
  match read_db.get_tournament_name().await {
    Some(name) => Ok(warp::reply::json(&name)),
    None => Ok(warp::reply::json(&""))
  }
}