use crate::database::SharedDatabase;

pub async fn tournament_schedule_set_csv_handler(request: String, _db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  log::debug!("Setting tournament csv schedule: {}", request);
  Ok(warp::http::StatusCode::OK)
}