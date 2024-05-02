use warp::Filter;
use crate::{database::SharedDatabase, network::{tournament_schedule_set_csv_handler, with_db, ClientMap}};

use super::header_filters::{auth_token_filter::check_auth_token_filter, role_permission_filter::role_permission_filter};


pub fn tournament_schedule_filter(clients: ClientMap, db: SharedDatabase) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
  let tournament_schedule_path = warp::path("tournament").and(warp::path("schedule"));
  
  let set_csv = tournament_schedule_path.and(warp::path("csv"))
    .and(warp::post())
    .and(warp::body::bytes())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["admin"]))
    .and_then(|bytes: warp::hyper::body::Bytes, db| {
      let body = String::from_utf8(bytes.to_vec()).unwrap();
      tournament_schedule_set_csv_handler(body, db)
    });


  set_csv
}