use tms_infra::RobotGameScoreSheetRequest;
use crate::{database::*, network::BadRequestWithMessage};

pub async fn robot_game_scoring_submit_score_sheet(request: RobotGameScoreSheetRequest, db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  // get team from team number
  let team_id: String = match db.read().await.get_team_by_number(request.team_number.to_owned()).await {
    Some(team) => team.0,
    None => {
      log::error!("Team not found: {}", request.team_number);
      return Err(warp::reject::not_found());
    }
  };

  let score_sheet = GameScoreSheet {
    table: request.table,
    team_ref_id: team_id,
    referee: request.referee,
    match_number: request.match_number,
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

  match db.write().await.insert_game_score_sheet(score_sheet, None).await {
    Ok(_) => log::info!("GameScoreSheet submitted: {}", request.team_number),
    Err(e) => {
      log::error!("Failed to submit GameScoreSheet: {}", e);
      return Err(warp::reject::custom(BadRequestWithMessage { message: e }));
    }
  }

  Ok(warp::http::StatusCode::OK)
}