use tms_infra::*;

use crate::database::*;

pub async fn judging_pod_insert_handler(request: JudgingPodInsertRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;

  match read_db.insert_judging_pod(request.pod, request.pod_id).await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(crate::network::BadRequestWithMessage { message: e })),
  }
}

pub async fn judging_pod_remove_handler(request: JudgingPodRemoveRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;

  match read_db.remove_judging_pod(request.pod_id).await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(crate::network::BadRequestWithMessage { message: e })),
  }
}