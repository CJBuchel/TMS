use rocket::{State, post, get, http::Status};
use tms_utils::TmsRouteResponse;

use crate::db::backup_service::BackupService;


// #[get("/backups/get/<uuid>")]
// pub async fn backups_get_route(uuid: String, backup_service: &State<BackupService>) -> TmsRouteResponse<()> {
  
// }