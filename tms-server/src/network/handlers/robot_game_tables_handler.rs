use tms_infra::RobotGameTableSignalRequest;

use crate::network::*;


pub async fn robot_game_tables_not_ready_signal_handler(request: RobotGameTableSignalRequest, clients: ClientMap) -> Result<impl warp::Reply, warp::Rejection> {
  clients.read().await.publish_not_ready_signal(request.table.to_owned(), request.team_number.to_owned());
  Ok(warp::http::StatusCode::OK)
}

pub async fn robot_game_tables_ready_signal_handler(request: RobotGameTableSignalRequest, clients: ClientMap) -> Result<impl warp::Reply, warp::Rejection> {
  clients.read().await.publish_ready_signal(request.table.to_owned(), request.team_number.to_owned());
  Ok(warp::http::StatusCode::OK)
}