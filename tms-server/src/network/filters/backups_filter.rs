use crate::{database::SharedDatabase, network::*};
use filters::header_filters::{auth_token_filter::check_auth_token_filter, role_permission_filter::role_permission_filter};
use warp::Filter;

pub fn backups_filter(clients: ClientMap, db: SharedDatabase) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
  let backups_path = warp::path("backup");

  let get_backups_path = backups_path
    .and(warp::path("names"))
    .and(warp::get())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec![]))
    .and_then(get_backups_handler);

  let download_backup_path = backups_path
    .and(warp::path("download"))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec![]))
    .and(warp::fs::dir("backups"));

  get_backups_path.or(download_backup_path)
}
