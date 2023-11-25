use schemars::JsonSchema;
use serde::{Deserialize, Serialize};
use crate::schemas::{Event, GameMatch, JudgingSession, User, Team, APILink};

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct SetupRequest {
  pub auth_token: String,
  pub admin_password: Option<String>,
  pub teams: Vec<Team>,
  pub matches: Vec<GameMatch>,
  pub judging_sessions: Vec<JudgingSession>,
  pub users: Vec<User>,
  pub event: Option<Event>,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct PurgeRequest {
  pub auth_token: String,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct ApiLinkRequest {
  pub auth_token: String,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct ApiLinkResponse {
  pub api_link: APILink,
}