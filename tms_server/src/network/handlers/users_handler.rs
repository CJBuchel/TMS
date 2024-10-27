use tms_infra::*;

use crate::database::*;


pub async fn user_insert_handler(request: UserInsertRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;

  let u_name = request.user.username.clone();

  if u_name.is_empty() || u_name == "admin" || u_name == "public" {
    return Err(warp::reject::custom(crate::network::BadRequestWithMessage { message: "Invalid user request".to_string() }));
  }

  match read_db.insert_user(request.user, request.user_id).await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(crate::network::BadRequestWithMessage { message: e })),
  }
}

pub async fn user_remove_handler(request: UserRemoveRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;

  match read_db.remove_user(request.user_id).await {
    Ok(_) => Ok(warp::http::StatusCode::OK),
    Err(e) => Err(warp::reject::custom(crate::network::BadRequestWithMessage { message: e })),
  }
}