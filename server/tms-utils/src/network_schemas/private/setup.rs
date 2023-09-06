use schemars::JsonSchema;
use serde::{Serialize, Deserialize};
use crate::schemas::{Event, GameMatch, JudgingSession, User, Team};


#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct SetupRequest {
  pub auth_token: String,
  pub admin_password: String,
  pub teams: Vec<Team>,
  pub matches: Vec<GameMatch>,
  pub judging_sessions: Vec<JudgingSession>,
  pub users: Vec<User>,
  pub event: Event,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct PurgeRequest {
  auth_token: String,
}