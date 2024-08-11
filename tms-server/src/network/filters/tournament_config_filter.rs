use warp::Filter;

use crate::network::*;
use crate::{database::*, network::ClientMap};
use crate::network::handlers::*;

use super::header_filters::{auth_token_filter::check_auth_token_filter, role_permission_filter::role_permission_filter};


pub fn tournament_config_filter(clients: ClientMap, db: SharedDatabase) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
  let tournament_config_path = warp::path("tournament").and(warp::path("config"));

  let tournament_event_name_path = tournament_config_path.and(warp::path("name"));

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

  let tournament_admin_password_path = tournament_config_path.and(warp::path("admin_password"));

  let set_admin_password = tournament_admin_password_path
    .and(warp::post())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["admin"]))
    .and_then(tournament_config_set_admin_password);

  let tournament_timer_length_path = tournament_config_path.and(warp::path("timer_length"));

  let set_timer_length = tournament_timer_length_path
    .and(warp::post())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["admin"]))
    .and_then(tournament_config_set_timer_length);

  let get_timer_length = tournament_timer_length_path
    .and(warp::get())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and_then(tournament_config_get_timer_length);

  let tournament_endgame_timer_length_path = tournament_config_path.and(warp::path("endgame_timer_length"));

  let set_endgame_timer_length = tournament_endgame_timer_length_path
    .and(warp::post())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["admin"]))
    .and_then(tournament_config_set_endgame_timer_length);

  let get_endgame_timer_length = tournament_endgame_timer_length_path
    .and(warp::get())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and_then(tournament_config_get_endgame_timer_length);

  let tournament_backup_interval_path = tournament_config_path.and(warp::path("backup_interval"));
  
  let set_backup_interval = tournament_backup_interval_path
    .and(warp::post())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["admin"]))
    .and_then(tournament_config_set_backup_interval);

  let get_backup_interval = tournament_backup_interval_path
    .and(warp::get())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and_then(tournament_config_get_backup_interval);

  let tournament_retain_backups_path = tournament_config_path.and(warp::path("retain_backups"));
  
  let set_retain_backups = tournament_retain_backups_path
    .and(warp::post())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["admin"]))
    .and_then(tournament_config_set_retain_backups);

  let get_retain_backups = tournament_retain_backups_path
    .and(warp::get())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and_then(tournament_config_get_retain_backups);

  let tournament_season_path = tournament_config_path.and(warp::path("season"));
  
  let set_season = tournament_season_path
    .and(warp::post())
    .and(warp::body::json())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["admin"]))
    .and_then(tournament_config_set_season);

  let get_season = tournament_season_path
    .and(warp::get())
    .and(with_db(db.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and_then(tournament_config_get_season);

  let tournament_purge_path = tournament_config_path.and(warp::path("purge"));

  let purge = tournament_purge_path
    .and(warp::post())
    .and(with_db(db.clone()))
    .and(with_clients(clients.clone()))
    .and(check_auth_token_filter(clients.clone()))
    .and(role_permission_filter(clients.clone(), db.clone(), vec!["admin"]))
    .and_then(tournament_config_purge);

  set_name.or(get_name)
    .or(set_admin_password)

    .or(set_timer_length)
    .or(get_timer_length)
    
    .or(set_endgame_timer_length)
    .or(get_endgame_timer_length)
    
    .or(set_backup_interval)
    .or(get_backup_interval)
    
    .or(set_retain_backups)
    .or(get_retain_backups)
    
    .or(set_season)
    .or(get_season)

    .or(purge)
}