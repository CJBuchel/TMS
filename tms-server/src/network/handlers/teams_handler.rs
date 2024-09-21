use tms_infra::TeamsUpdateTeamRequest;

use crate::database::{SharedDatabase, TeamExtensions};


pub async fn team_update_team_handler(request: TeamsUpdateTeamRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;

  match read_db.insert_team(request.team, Some(request.team_id)).await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(crate::network::BadRequestWithMessage { message: e })),
  }
}