use tms_infra::{TeamsAddTeamRequest, TeamsRemoveTeamRequest, TeamsUpdateTeamRequest};

use crate::database::{SharedDatabase, TeamExtensions};


pub async fn teams_update_team_handler(request: TeamsUpdateTeamRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;

  match read_db.insert_team(request.team, Some(request.team_id)).await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(crate::network::BadRequestWithMessage { message: e })),
  }
}

pub async fn teams_add_team_handler(request: TeamsAddTeamRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;

  match read_db.insert_team(request.team, None).await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(crate::network::BadRequestWithMessage { message: e })),
  }
}

pub async fn teams_remove_team_handler(request: TeamsRemoveTeamRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;

  match read_db.remove_team(request.team_id).await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(crate::network::BadRequestWithMessage { message: e })),
  }
}