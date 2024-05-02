use warp::Filter;

use crate::{database::SharedDatabase, network::{tournament_config_get_name_handler, tournament_config_set_name_handler, with_db, ClientMap}};

use super::header_filters::{auth_token_filter::check_auth_token_filter, role_permission_filter::role_permission_filter};


pub fn tournament_config_filter(clients: ClientMap, db: SharedDatabase) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
  

  let tournament_event_name_path = warp::path("tournament").and(warp::path("config")).and(warp::path("name"));

  let set_name = tournament_event_name_path
    .and(warp::post())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["admin"]))
    .and_then(tournament_config_set_name_handler);

  let get_name = tournament_event_name_path
    .and(warp::get())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and_then(tournament_config_get_name_handler);

  set_name.or(get_name)
}