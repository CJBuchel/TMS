use tms_infra::*;

use crate::{database::*, network::*};


pub async fn robot_game_table_not_ready_signal_handler(request: RobotGameTableSignalRequest, clients: ClientMap) -> Result<impl warp::Reply, warp::Rejection> {
  clients.read().await.publish_not_ready_signal(request.table.to_owned(), request.team_number.to_owned());
  Ok(warp::http::StatusCode::OK)
}

pub async fn robot_game_table_ready_signal_handler(request: RobotGameTableSignalRequest, clients: ClientMap) -> Result<impl warp::Reply, warp::Rejection> {
  clients.read().await.publish_ready_signal(request.table.to_owned(), request.team_number.to_owned());
  Ok(warp::http::StatusCode::OK)
}

pub async fn robot_game_table_insert_handler(request: RobotGameTableInsertRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;
  match read_db.insert_game_table(request.table, request.table_id).await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(BadRequestWithMessage { message: e })),
  }
}

pub async fn robot_game_table_remove_handler(request: RobotGameTableRemoveRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;
  match read_db.remove_game_table(request.table_id.to_owned()).await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(BadRequestWithMessage { message: e })),
  }
}