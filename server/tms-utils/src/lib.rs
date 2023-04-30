use rocket::{http::Status, serde::json::Json};
pub type RouteResponse<T,E> = Result<(Status, Json<T>), E>;

#[macro_export]
macro_rules! Respond {
  () => {
    return Ok((Status::Ok, Json({})))
  };

  ($status:expr) => {
    return Ok(($status, Json({})))
  };

  ($status:expr, $data:expr) => {
    return Ok(($status, Json($data)))
  }
}