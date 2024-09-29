use tms_infra::*;

use crate::database::*;

pub async fn judging_session_insert_handler(request: JudgingSessionInsertRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;

  match read_db.insert_judging_session(request.session, request.session_id).await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(crate::network::BadRequestWithMessage { message: e })),
  }
}

pub async fn judging_session_remove_handler(request: JudgingSessionRemoveRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;

  match read_db.remove_judging_session(request.session_id).await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(crate::network::BadRequestWithMessage { message: e })),
  }
}