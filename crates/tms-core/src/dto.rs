//! REST request and response bodies.

use chrono::{DateTime, NaiveDate, NaiveDateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::Role;
use crate::model::{BlockKind, EventSettings, MatchKind};
use crate::validation::ScheduleIssue;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "sqlx", derive(sqlx::Type))]
#[cfg_attr(feature = "sqlx", sqlx(type_name = "event_status", rename_all = "snake_case"))]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(rename_all = "snake_case")]
pub enum EventStatus {
  Draft,
  Active,
  Archived,
}

impl EventStatus {
  pub fn label(self) -> &'static str {
    match self {
      EventStatus::Draft => "Draft",
      EventStatus::Active => "Active",
      EventStatus::Archived => "Archived",
    }
  }
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct EventSummary {
  pub id: Uuid,
  pub code: String,
  pub name: String,
  pub season_id: String,
  pub timezone: String,
  pub starts_on: NaiveDate,
  pub ends_on: NaiveDate,
  pub status: EventStatus,
  #[serde(default)]
  pub settings: EventSettings,
}

/// Everything about an event that can change after creation. The code is fixed: it is printed on scoresheets.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct UpdateEventRequest {
  pub name: String,
  pub season_id: String,
  pub timezone: String,
  pub starts_on: NaiveDate,
  pub ends_on: NaiveDate,
  pub settings: EventSettings,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct Season {
  pub id: String,
  pub name: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct TeamInput {
  pub number: String,
  pub name: String,
  pub affiliation: String,
  pub pit: Option<String>,
  #[serde(default)]
  pub notes: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct TableInput {
  pub name: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct PodInput {
  pub name: String,
  pub room: Option<String>,
}

/// The complete new order, by id.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct ReorderRequest {
  pub ids: Vec<Uuid>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct BlockInput {
  pub kind: BlockKind,
  pub name: String,
  /// Wall-clock time at the event (the event's timezone), as typed into a form. The server converts to UTC.
  pub starts_local: NaiveDateTime,
  pub ends_local: NaiveDateTime,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct UserSummary {
  pub id: Uuid,
  pub username: String,
  pub display_name: String,
  pub roles: Vec<Role>,
  pub disabled: bool,
  pub must_change_password: bool,
  pub created_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct CreateUserRequest {
  pub username: String,
  pub display_name: String,
  pub roles: Vec<Role>,
  /// Chosen by the admin. Absent or empty gives a one-time password, changed at first login.
  #[serde(default)]
  pub password: Option<String>,
}

/// A password the admin chooses for a user; absent or empty gives a one-time password, changed at first login.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct SetPasswordRequest {
  #[serde(default)]
  pub password: Option<String>,
}

/// Only the fields present change.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct UpdateUserRequest {
  pub display_name: Option<String>,
  pub roles: Option<Vec<Role>>,
  pub disabled: Option<bool>,
}

/// A new or reset account. The password is shown once and must be changed at first login.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct OneTimePassword {
  pub user: UserSummary,
  pub password: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct AuditEntry {
  pub id: i64,
  pub event_id: Option<Uuid>,
  pub actor: String,
  pub action: String,
  pub entity_type: String,
  pub entity_id: Option<Uuid>,
  pub data: serde_json::Value,
  pub at: DateTime<Utc>,
}

/// What a schedule import would change, returned by the dry run and again by the commit.
#[derive(Debug, Clone, PartialEq, Default, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct ImportPreview {
  pub teams_added: Vec<String>,
  pub teams_updated: Vec<String>,
  /// Teams already in TMS that the file does not mention. They are kept.
  pub teams_not_in_file: Vec<String>,
  pub tables_added: Vec<String>,
  pub pods_added: Vec<String>,
  pub practice_matches: usize,
  pub ranking_matches: usize,
  pub judging_sessions: usize,
  /// Matches and sessions already in TMS, which the commit replaces.
  pub replaces_matches: i64,
  pub replaces_sessions: i64,
  pub days: Vec<NaiveDate>,
  pub warnings: Vec<String>,
  /// What the schedule checks find in the new schedule.
  #[serde(default)]
  pub issues: Vec<ScheduleIssue>,
}

/// Builds a schedule from the event's teams, tables, pods, settings and timetable breaks.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct GenerateRequest {
  /// Event-local time of the first match.
  pub match_start_local: NaiveDateTime,
  /// Event-local time of the first judging session.
  pub judging_start_local: NaiveDateTime,
  /// From one match's start to the next.
  pub match_cycle_minutes: u32,
  /// The same request with the same seed gives the same schedule.
  pub seed: u64,
}

/// A generated schedule to look over before committing it.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct GeneratePreview {
  pub preview: ImportPreview,
  pub matches: Vec<ProposedEntry>,
  pub sessions: Vec<ProposedEntry>,
}

/// A match or judging session in a proposed schedule.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct ProposedEntry {
  /// `None` for a judging session.
  pub kind: Option<MatchKind>,
  pub number: i32,
  pub start: DateTime<Utc>,
  pub end: DateTime<Utc>,
  /// Table or pod name, and team number.
  pub teams: Vec<(String, String)>,
}

/// Puts a team in a match or judging slot, or empties it.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct SlotAssignRequest {
  pub team_id: Option<Uuid>,
  /// Save even though it creates schedule errors.
  #[serde(default)]
  pub force: bool,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct SlotSwapRequest {
  pub a: Uuid,
  pub b: Uuid,
  #[serde(default)]
  pub force: bool,
}

/// Moves a match or judging session, keeping its length.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct MoveRequest {
  pub start_local: NaiveDateTime,
  #[serde(default)]
  pub force: bool,
}

/// What swapping a slot with another would do to the schedule.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct SwapOption {
  pub slot_id: Uuid,
  pub match_id: Uuid,
  pub label: String,
  pub start: DateTime<Utc>,
  pub team_id: Option<Uuid>,
  /// Errors the swap would add.
  pub new_errors: Vec<String>,
  /// Change in the number of warnings for the teams involved.
  pub warnings: i32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct CreateEventRequest {
  pub code: String,
  pub name: String,
  pub season_id: String,
  pub timezone: String,
  pub starts_on: NaiveDate,
  pub ends_on: NaiveDate,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "sqlx", derive(sqlx::Type))]
#[cfg_attr(feature = "sqlx", sqlx(type_name = "banner_severity", rename_all = "snake_case"))]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(rename_all = "snake_case")]
pub enum BannerSeverity {
  Info,
  Success,
  Warning,
  Error,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct Banner {
  pub id: Uuid,
  pub event_id: Uuid,
  pub severity: BannerSeverity,
  pub message: String,
  pub created_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct CreateBannerRequest {
  pub severity: BannerSeverity,
  pub message: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct LoginRequest {
  pub username: String,
  pub password: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct KeyLoginRequest {
  pub key: String,
}

/// Who a login token belongs to: a user or an event access key.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(tag = "kind", rename_all = "snake_case")]
pub enum Principal {
  User {
    user_id: Uuid,
    username: String,
    display_name: String,
  },
  Key {
    key_id: Uuid,
    event_id: Uuid,
    label: String,
    /// The table or pod this device serves, when the key was bound to one.
    #[serde(default)]
    table_id: Option<Uuid>,
    #[serde(default)]
    pod_id: Option<Uuid>,
  },
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct Identity {
  pub principal: Principal,
  pub roles: Vec<Role>,
  pub must_change_password: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct AuthResponse {
  pub token: String,
  pub expires_at: DateTime<Utc>,
  pub identity: Identity,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct ChangePasswordRequest {
  pub current_password: String,
  pub new_password: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct AccessKeySummary {
  pub id: Uuid,
  pub event_id: Uuid,
  pub prefix: String,
  pub label: String,
  pub roles: Vec<Role>,
  pub table_id: Option<Uuid>,
  pub pod_id: Option<Uuid>,
  pub expires_at: Option<DateTime<Utc>>,
  pub revoked_at: Option<DateTime<Utc>>,
  pub last_used_at: Option<DateTime<Utc>>,
  pub created_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct CreateAccessKeyRequest {
  pub label: String,
  pub role: Role,
  /// Binds a referee (or head referee) station to a table.
  #[serde(default)]
  pub table_id: Option<Uuid>,
  /// Binds a judge (or judge advisor) station to a pod.
  #[serde(default)]
  pub pod_id: Option<Uuid>,
  pub expires_at: Option<DateTime<Utc>>,
}

/// Returned once on creation. The plaintext key is never retrievable again.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct CreatedAccessKey {
  pub key: String,
  pub summary: AccessKeySummary,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct ApiErrorBody {
  pub code: String,
  pub message: String,
  /// Individual problems, for errors that have several (such as a schedule file with bad lines).
  #[serde(default, skip_serializing_if = "Vec::is_empty")]
  pub details: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct VersionInfo {
  pub version: String,
  pub protocol: u16,
}
