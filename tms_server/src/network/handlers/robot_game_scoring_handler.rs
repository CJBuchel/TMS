use tms_infra::*;

use crate::{database::*, network::*};


pub async fn robot_game_score_sheet_remove_handler(request: RobotGameScoreSheetRemoveRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;
  match read_db.remove_game_score_sheet(request.score_sheet_id.to_owned()).await {
    Ok(_) => {
      log::info!("GameScoreSheet removed: {}", request.score_sheet_id);
      Ok(warp::http::StatusCode::OK)
    },
    Err(e) => {
      log::error!("Failed to delete GameScoreSheet: {}", e);
      return Err(warp::reject::custom(BadRequestWithMessage { message: e }));
    }
  }
}

pub async fn robot_game_score_sheet_insert_handler(request: RobotGameScoreSheetInsertRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;
  match read_db.insert_game_score_sheet(request.score_sheet, request.score_sheet_id.to_owned()).await {
    Ok(_) => Ok(warp::http::StatusCode::OK)
    ,
    Err(e) => {
      log::error!("Failed to update GameScoreSheet: {}", e);
      return Err(warp::reject::custom(BadRequestWithMessage { message: e }));
    }
  }
}

pub async fn robot_game_score_sheet_submit_handler(request: RobotGameScoreSheetSubmitRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  // get team from team number
  let team_id: String = match db.read().await.get_team_by_number(request.team_number.to_owned()).await {
    Some(team) => team.0,
    None => {
      log::error!("Team not found: {}", request.team_number);
      return Err(warp::reject::not_found());
    }
  };

  let score_sheet = GameScoreSheet {
    blueprint_title: request.blueprint_title.clone(),
    table: request.table.clone(),
    team_ref_id: team_id,
    referee: request.referee,
    match_number: request.match_number.clone(),
    timestamp: TmsDateTime::now(),

    gp: request.gp,
    no_show: request.no_show,
    score: request.score,
    round: request.round,

    is_agnostic: request.is_agnostic,
    score_sheet_answers: request.score_sheet_answers,

    private_comment: request.private_comment,

    modified: false,
    modified_by: None,
  };

  let read_db = db.read().await;

  match read_db.insert_game_score_sheet(score_sheet, None).await {
    Ok(_) => {
      log::info!("GameScoreSheet submitted for team: {}", request.team_number);
    },
    Err(e) => {
      log::error!("Failed to submit GameScoreSheet: {}", e);
      return Err(warp::reject::custom(BadRequestWithMessage { message: e }));
    }
  }

  // if match number is provided, set game match table to score submitted
  if let Some(game_match_number) = request.match_number {
    let game_match_id = match read_db.get_game_match_by_number(game_match_number.to_owned()).await {
      Some((id, _)) => id,
      None => {
        log::error!("GameMatch not found: {}, cannot update table", game_match_number);
        return Err(warp::reject::not_found());
      }
    };

    // update game match table score submitted
    match read_db.set_game_match_table_score_submitted(game_match_id, request.table.clone()).await {
      Ok(_) => {
        log::info!("Updated game match: {}, table: {}", game_match_number, request.table.to_owned());
      },
      Err(e) => {
        log::error!("Failed to update GameMatch table score submitted: {}", e);
        return Err(warp::reject::custom(BadRequestWithMessage { message: e }));
      }
    }
  }

  Ok(warp::http::StatusCode::OK)
}