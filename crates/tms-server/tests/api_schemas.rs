//! Keeps the JSON Schemas in docs/api/schemas in step with the Rust types, so the docs site always describes
//! the real API. Running the tests rewrites them; a changed file shows up in the diff.

use std::path::{Path, PathBuf};

use schemars::{JsonSchema, schema_for};
use tms_core::ws::{ClientMessage, ServerMessage};
use tms_core::{dto, game};

fn write<T: JsonSchema>(dir: &Path, name: &str) {
  let json = serde_json::to_string_pretty(&schema_for!(T)).unwrap() + "\n";
  std::fs::write(dir.join(format!("{name}.json")), json).unwrap();
}

#[test]
fn api_schemas_are_written_to_the_docs() {
  let dir = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../../docs/api/schemas");
  std::fs::create_dir_all(&dir).unwrap();
  write::<ClientMessage>(&dir, "ws-client-message");
  write::<ServerMessage>(&dir, "ws-server-message");
  write::<dto::LoginRequest>(&dir, "login-request");
  write::<dto::KeyLoginRequest>(&dir, "key-login-request");
  write::<dto::AuthResponse>(&dir, "auth-response");
  write::<dto::ChangePasswordRequest>(&dir, "change-password-request");
  write::<dto::EventSummary>(&dir, "event-summary");
  write::<dto::CreateEventRequest>(&dir, "create-event-request");
  write::<dto::CreateAccessKeyRequest>(&dir, "create-access-key-request");
  write::<dto::CreatedAccessKey>(&dir, "created-access-key");
  write::<dto::CreateBannerRequest>(&dir, "create-banner-request");
  write::<dto::ApiErrorBody>(&dir, "api-error");
  write::<game::ScoresheetDoc>(&dir, "scoresheet-doc");
  write::<game::SyncScoresheetsRequest>(&dir, "sync-scoresheets-request");
  write::<game::SyncScoresheetsResponse>(&dir, "sync-scoresheets-response");
  write::<game::Scoresheet>(&dir, "scoresheet");
  write::<game::StageRequest>(&dir, "stage-request");
  write::<game::TimerStartRequest>(&dir, "timer-start-request");
  write::<game::ReviewRequest>(&dir, "review-request");
  write::<game::MatchTimer>(&dir, "match-timer");
  write::<game::RankingRow>(&dir, "ranking-row");
}
