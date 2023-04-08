include!("./answer.rs");

#[derive(JsonSchema, Clone)]
pub struct GameScoresheet {
  team_id: String,
  tournament_id: String,
  round: u8,
  answers: Vec<Answer>,
  private_comment: String,
  public_comment: String
}