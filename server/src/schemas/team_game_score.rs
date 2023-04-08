include!("./game_scoresheet.rs");

#[derive(JsonSchema, Clone)]
pub struct TeamGameScore {
  gp: String,
  referee: String,
  no_show: bool,
  score: u32,
  valid_scoresheet: bool,
  cloud_published: bool,
  scoresheet: GameScoresheet
}