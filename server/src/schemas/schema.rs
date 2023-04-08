use schemars::JsonSchema;

include!("./event.rs");
include!("./user.rs");
include!("./judging_session.rs");
include!("./match.rs");
include!("./team_game_score.rs");

// Generates json structure called TmsSchema, includes all data structures for comms and database
#[derive(JsonSchema, Clone)]
pub struct TmsSchema {
  pub event: Event,
  pub user: User,
  pub judging_session: JudgingSession,
  pub game_match: Match,
  pub team_game_score: TeamGameScore
}