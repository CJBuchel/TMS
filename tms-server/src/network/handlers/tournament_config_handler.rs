use tms_infra::*;

use crate::{database::*, network::*};


pub async fn tournament_config_set_name_handler(request: TournamentConfigSetNameRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let mut write_db = db.write().await;
  log::info!("Setting tournament name to: {}", request.name);
  write_db.set_tournament_name(request.name).await;
  Ok(warp::http::StatusCode::OK)
}

pub async fn tournament_config_get_name_handler(db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;
  match read_db.get_tournament_name().await {
    Some(name) => Ok(warp::reply::json(&name)),
    None => Ok(warp::reply::json(&"")),
  }
}

pub async fn tournament_config_set_admin_password(request: TournamentConfigSetAdminPasswordRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;
  log::info!("Setting admin password to: {}", request.admin_password);

  let admin_user = User {
    username: "admin".to_string(),
    password: request.admin_password.clone(),
    roles: vec!["admin".to_string()],
  };

  match read_db.insert_user(admin_user, None).await {
    Ok(_) => {
      log::info!("Admin password set");
      Ok(warp::http::StatusCode::OK)
    }
    Err(e) => {
      log::error!("Failed to set admin password: {}", e);
      Ok(warp::http::StatusCode::INTERNAL_SERVER_ERROR)
    }
  }
}

pub async fn tournament_config_set_timer_length(request: TournamentConfigSetTimerLengthRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let mut write_db = db.write().await;
  log::info!("Setting tournament timer length to: {}", request.timer_length);
  write_db.set_tournament_timer_length(request.timer_length).await;
  Ok(warp::http::StatusCode::OK)
}

pub async fn tournament_config_get_timer_length(db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;
  match read_db.get_tournament_timer_length().await {
    Some(timer_length) => Ok(warp::reply::json(&timer_length)),
    None => Ok(warp::reply::json(&0)),
  }
}

pub async fn tournament_config_set_endgame_timer_length(request: TournamentConfigSetEndgameTimerLengthRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let mut write_db = db.write().await;
  log::info!("Setting tournament endgame timer length to: {}", request.timer_length);
  write_db.set_tournament_endgame_timer_length(request.timer_length).await;
  Ok(warp::http::StatusCode::OK)
}

pub async fn tournament_config_get_endgame_timer_length(db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;
  match read_db.get_tournament_endgame_timer_length().await {
    Some(timer_length) => Ok(warp::reply::json(&timer_length)),
    None => Ok(warp::reply::json(&0)),
  }
}

pub async fn tournament_config_set_backup_interval(request: TournamentConfigSetBackupIntervalRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let mut write_db = db.write().await;
  log::info!("Setting tournament backup interval to: {}", request.interval);
  write_db.set_tournament_backup_interval(request.interval).await;
  Ok(warp::http::StatusCode::OK)
}

pub async fn tournament_config_get_backup_interval(db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;
  match read_db.get_tournament_backup_interval().await {
    Some(interval) => Ok(warp::reply::json(&interval)),
    None => Ok(warp::reply::json(&0)),
  }
}

pub async fn tournament_config_set_retain_backups(request: TournamentConfigSetRetainBackupsRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let mut write_db = db.write().await;
  log::info!("Setting tournament retain backups to: {}", request.retain_backups);
  write_db.set_tournament_retain_backups(request.retain_backups).await;
  Ok(warp::http::StatusCode::OK)
}

pub async fn tournament_config_get_retain_backups(db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;
  match read_db.get_tournament_retain_backups().await {
    Some(retain_backups) => Ok(warp::reply::json(&retain_backups)),
    None => Ok(warp::reply::json(&0)),
  }
}

pub async fn tournament_config_set_season(request: TournamentConfigSetSeasonRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let mut write_db = db.write().await;

  write_db.set_tournament_blueprint_type(request.blueprint_type).await;

  match request.season {
    Some(season) => {
      log::info!("Setting tournament season to: {}", season);
      write_db.set_tournament_season(season).await;
    }
    _ => {}
  }
  Ok(warp::http::StatusCode::OK)
}

pub async fn tournament_config_get_season(db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;
  match read_db.get_tournament_season().await {
    Some(season) => Ok(warp::reply::json(&season)),
    None => Ok(warp::reply::json(&"")),
  }
}

pub async fn tournament_config_purge(db: SharedDatabase, clients: ClientMap) -> Result<impl warp::Reply, warp::Rejection> {
  let mut write_db = db.write().await;
  write_db.purge().await;
  // publish the purge message to all clients
  clients.read().await.publish_purge();
  Ok(warp::http::StatusCode::OK)
}
