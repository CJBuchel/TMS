use crate::database::*;



pub async fn tournament_blueprint_add_blueprint_handler(_request: String, _db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  Ok(warp::http::StatusCode::OK)
}