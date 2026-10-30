//! Phase 1: event setup over REST, with the live feed following along.

mod common;

use common::{TestApp, error_code, ok_json};
use reqwest::StatusCode;
use tms_core::dto::{
  AccessKeySummary, AuditEntry, AuthResponse, CreatedAccessKey, EventSummary, ImportPreview, OneTimePassword,
  Principal, UserSummary,
};
use tms_core::model::{GameMatch, GameTable, JudgingSession, MatchKind, Pod, Team};
use tms_core::ws::{ClientMessage, ServerMessage, TopicItem};
use tms_core::{Role, Topic};

const SCHEDULE: &str = include_str!("../../tms-schedule/tests/fixtures/single_day.csv");
const MULTI_DAY: &str = include_str!("../../tms-schedule/tests/fixtures/multi_day.csv");

fn team(number: &str, name: &str) -> serde_json::Value {
  serde_json::json!({"number": number, "name": name, "affiliation": "School", "pit": null, "notes": ""})
}

#[tokio::test]
async fn teams_crud_with_live_updates() {
  let app = TestApp::spawn().await;
  let admin = app.admin_token().await;
  let event = app.active_event(&admin, "SET-01").await;

  let mut ws = app.ws_ready(None).await;
  ws.send(&ClientMessage::SetSubscriptions {
    topics: vec![Topic::Teams],
  })
  .await;
  assert_eq!(
    ws.recv().await,
    ServerMessage::Snapshot {
      topic: Topic::Teams,
      items: vec![]
    }
  );

  let created: Team = ok_json(
    app
      .post(
        Some(&admin),
        &format!("/events/{}/teams", event.id),
        &team(" 1234 ", "Robo"),
      )
      .await,
  )
  .await;
  assert_eq!(created.number, "1234", "input is trimmed");
  assert_eq!(
    ws.recv().await,
    ServerMessage::Upsert {
      topic: Topic::Teams,
      item: TopicItem::Team(created.clone())
    }
  );

  let dup = app
    .post(
      Some(&admin),
      &format!("/events/{}/teams", event.id),
      &team("1234", "Other"),
    )
    .await;
  assert_eq!(
    error_code(dup).await,
    (StatusCode::CONFLICT, "team.duplicate_number".into())
  );
  let blank = app
    .post(Some(&admin), &format!("/events/{}/teams", event.id), &team("", "Name"))
    .await;
  assert_eq!(error_code(blank).await.1, "input.required");

  let renamed: Team = ok_json(
    app
      .patch(&admin, &format!("/teams/{}", created.id), &team("1234", "Robo Two"))
      .await,
  )
  .await;
  assert_eq!(renamed.name, "Robo Two");
  assert!(matches!(ws.recv().await, ServerMessage::Upsert { item: TopicItem::Team(t), .. } if t.name == "Robo Two"));

  assert_eq!(
    app.delete(&admin, &format!("/teams/{}", created.id)).await.status(),
    StatusCode::NO_CONTENT
  );
  assert_eq!(
    ws.recv().await,
    ServerMessage::Delete {
      topic: Topic::Teams,
      id: created.id
    }
  );

  // A referee key cannot change teams.
  let key: CreatedAccessKey = ok_json(
    app
      .post(
        Some(&admin),
        &format!("/events/{}/keys", event.id),
        &serde_json::json!({"label": "T1", "role": "referee"}),
      )
      .await,
  )
  .await;
  let referee: AuthResponse = ok_json(app.post(None, "/auth/key", &serde_json::json!({"key": key.key})).await).await;
  let refused = app
    .post(
      Some(&referee.token),
      &format!("/events/{}/teams", event.id),
      &team("9", "Nope"),
    )
    .await;
  assert_eq!(refused.status(), StatusCode::FORBIDDEN);
}

#[tokio::test]
async fn tables_and_pods_keep_their_order() {
  let app = TestApp::spawn().await;
  let admin = app.admin_token().await;
  let event = app.active_event(&admin, "SET-02").await;
  let path = format!("/events/{}/tables", event.id);
  let mut ids = Vec::new();
  for name in ["A", "B", "C"] {
    let table: GameTable = ok_json(app.post(Some(&admin), &path, &serde_json::json!({"name": name})).await).await;
    ids.push(table.id);
  }
  ids.reverse();
  let reordered: Vec<GameTable> = ok_json(
    app
      .post(Some(&admin), &format!("{path}/order"), &serde_json::json!({"ids": ids}))
      .await,
  )
  .await;
  assert_eq!(
    reordered.iter().map(|t| t.name.as_str()).collect::<Vec<_>>(),
    vec!["C", "B", "A"]
  );

  let pod: Pod = ok_json(
    app
      .post(
        Some(&admin),
        &format!("/events/{}/pods", event.id),
        &serde_json::json!({"name": "Pod 1", "room": " "}),
      )
      .await,
  )
  .await;
  assert_eq!(pod.room, None, "a blank room is no room");
  let updated: Pod = ok_json(
    app
      .patch(
        &admin,
        &format!("/pods/{}", pod.id),
        &serde_json::json!({"name": "Pod 1", "room": "Hall B"}),
      )
      .await,
  )
  .await;
  assert_eq!(updated.room.as_deref(), Some("Hall B"));
}

#[tokio::test]
async fn schedule_import_dry_run_then_commit() {
  let app = TestApp::spawn().await;
  let admin = app.admin_token().await;
  let event = app.active_event(&admin, "SET-03").await;
  let import = format!("/events/{}/import/tiab", event.id);

  let preview: ImportPreview = ok_json(app.post_text(&admin, &import, SCHEDULE).await).await;
  assert_eq!(preview.teams_added.len(), 40);
  assert_eq!(
    preview.tables_added,
    vec!["Red", "Blue", "Pink", "Yellow", "Green", "Black"]
  );
  assert_eq!(preview.pods_added.len(), 10);
  assert_eq!(
    (
      preview.practice_matches,
      preview.ranking_matches,
      preview.judging_sessions
    ),
    (0, 60, 4)
  );
  let teams: Vec<Team> = ok_json(app.get(Some(&admin), &format!("/events/{}/teams", event.id)).await).await;
  assert!(teams.is_empty(), "a dry run changes nothing");

  let mut ws = app.ws_ready(None).await;
  ws.send(&ClientMessage::SetSubscriptions {
    topics: vec![Topic::Matches],
  })
  .await;
  assert_eq!(
    ws.recv().await,
    ServerMessage::Snapshot {
      topic: Topic::Matches,
      items: vec![]
    }
  );

  let committed: ImportPreview = ok_json(app.post_text(&admin, &format!("{import}?commit=true"), SCHEDULE).await).await;
  assert_eq!(committed, preview);
  match ws.recv().await {
    ServerMessage::Snapshot {
      topic: Topic::Matches,
      items,
    } => assert_eq!(items.len(), 60, "subscribers get the new schedule"),
    other => panic!("expected a matches snapshot, got {other:?}"),
  }

  let matches: Vec<GameMatch> = ok_json(app.get(Some(&admin), &format!("/events/{}/matches", event.id)).await).await;
  assert_eq!(matches.len(), 60);
  assert!(
    matches
      .iter()
      .all(|m| m.kind == MatchKind::Ranking && m.slots.len() == 2)
  );
  assert!(
    matches.windows(2).all(|w| w[0].scheduled_start <= w[1].scheduled_start),
    "in time order"
  );
  let sessions: Vec<JudgingSession> = ok_json(
    app
      .get(Some(&admin), &format!("/events/{}/judging-sessions", event.id))
      .await,
  )
  .await;
  assert_eq!(sessions.iter().map(|s| s.slots.len()).sum::<usize>(), 40);

  // Importing again replaces the schedule instead of duplicating it.
  let again: ImportPreview = ok_json(app.post_text(&admin, &format!("{import}?commit=true"), SCHEDULE).await).await;
  assert_eq!(
    (again.teams_added.len(), again.replaces_matches, again.replaces_sessions),
    (0, 60, 4)
  );
  let matches: Vec<GameMatch> = ok_json(app.get(Some(&admin), &format!("/events/{}/matches", event.id)).await).await;
  assert_eq!(matches.len(), 60);

  // A scheduled team cannot be deleted.
  let teams: Vec<Team> = ok_json(app.get(Some(&admin), &format!("/events/{}/teams", event.id)).await).await;
  let refused = app.delete(&admin, &format!("/teams/{}", teams[0].id)).await;
  assert_eq!(
    error_code(refused).await,
    (StatusCode::CONFLICT, "conflict.in_use".into())
  );
}

#[tokio::test]
async fn bad_schedules_are_refused_with_every_problem_listed() {
  let app = TestApp::spawn().await;
  let admin = app.admin_token().await;
  let event = app.active_event(&admin, "SET-04").await;
  let import = format!("/events/{}/import/tiab?commit=true", event.id);

  let res = app
    .post_text(
      &admin,
      &import,
      "Version Number,1\nBlock Format,1\n1,A,S\nBlock Format,2\nTable Names,T1\n1,9:00 AM,9:04 AM,77\n",
    )
    .await;
  assert_eq!(res.status(), StatusCode::UNPROCESSABLE_ENTITY);
  let body: serde_json::Value = res.json().await.unwrap();
  assert_eq!(body["code"], "import.invalid");
  assert!(body["details"][0].as_str().unwrap().contains("team 77"), "{body}");

  // The multi-day sample does not fit a one-day event.
  let res = app.post_text(&admin, &import, MULTI_DAY).await;
  let body: serde_json::Value = res.json().await.unwrap();
  assert!(body["details"][0].as_str().unwrap().contains("covers 2 days"), "{body}");
  let teams: Vec<Team> = ok_json(app.get(Some(&admin), &format!("/events/{}/teams", event.id)).await).await;
  assert!(teams.is_empty(), "nothing was written");
}

#[tokio::test]
async fn event_settings_are_validated_and_pushed() {
  let app = TestApp::spawn().await;
  let admin = app.admin_token().await;
  let event = app.active_event(&admin, "SET-05").await;
  let mut ws = app.ws_ready(None).await;
  ws.send(&ClientMessage::SetSubscriptions {
    topics: vec![Topic::Event],
  })
  .await;
  ws.recv().await;

  let mut body = serde_json::json!({
    "name": "Renamed", "season_id": "bioglow_founders", "timezone": "Australia/Perth",
    "starts_on": "2026-11-14", "ends_on": "2026-11-15", "settings": event.settings,
  });
  body["settings"]["endgame_seconds"] = serde_json::json!(500);
  let res = app.patch(&admin, &format!("/events/{}", event.id), &body).await;
  assert_eq!(res.status(), StatusCode::UNPROCESSABLE_ENTITY);

  body["settings"]["endgame_seconds"] = serde_json::json!(20);
  let updated: EventSummary = ok_json(app.patch(&admin, &format!("/events/{}", event.id), &body).await).await;
  assert_eq!(
    (
      updated.name.as_str(),
      updated.settings.endgame_seconds,
      updated.code.as_str()
    ),
    ("Renamed", 20, "SET-05")
  );
  assert_eq!(
    ws.recv().await,
    ServerMessage::Upsert {
      topic: Topic::Event,
      item: TopicItem::Event(updated)
    }
  );
}

#[tokio::test]
async fn users_lifecycle() {
  let app = TestApp::spawn().await;
  let admin = app.admin_token().await;

  let created: OneTimePassword = ok_json(
    app
      .post(
        Some(&admin),
        "/users",
        &serde_json::json!({"username": " Head-Ref ", "display_name": "Sam", "roles": ["head_referee"]}),
      )
      .await,
  )
  .await;
  assert_eq!(created.user.username, "head-ref");
  assert!(created.user.must_change_password);
  let login: AuthResponse = ok_json(app.login("head-ref", &created.password).await).await;
  assert!(
    login.identity.must_change_password,
    "a one-time password must be changed"
  );

  let chosen: OneTimePassword = ok_json(
    app
      .post(
        Some(&admin),
        "/users",
        &serde_json::json!({"username": "connor", "display_name": "Connor", "roles": ["admin"], "password": "my-own-password"}),
      )
      .await,
  )
  .await;
  assert!(
    !chosen.user.must_change_password,
    "a password the admin chose needs no change"
  );
  let login: AuthResponse = ok_json(app.login("connor", "my-own-password").await).await;
  assert!(!login.identity.must_change_password);
  let short = app
    .post(
      Some(&admin),
      "/users",
      &serde_json::json!({"username": "shorty", "display_name": "S", "roles": ["judge"], "password": "short"}),
    )
    .await;
  assert_eq!(error_code(short).await.1, "auth.password_too_short");
  let reset: OneTimePassword = ok_json(
    app
      .post(
        Some(&admin),
        &format!("/users/{}/reset-password", chosen.user.id),
        &serde_json::json!({"password": "another-password"}),
      )
      .await,
  )
  .await;
  assert!(!reset.user.must_change_password);
  assert_eq!(app.login("connor", "another-password").await.status(), StatusCode::OK);

  let taken = app
    .post(
      Some(&admin),
      "/users",
      &serde_json::json!({"username": "head-ref", "display_name": "X", "roles": ["judge"]}),
    )
    .await;
  assert_eq!(error_code(taken).await.1, "user.duplicate");
  let bad = app
    .post(
      Some(&admin),
      "/users",
      &serde_json::json!({"username": "a b", "display_name": "X", "roles": ["judge"]}),
    )
    .await;
  assert_eq!(error_code(bad).await.1, "user.invalid_username");

  // Changing roles ends existing logins.
  let changed: UserSummary = ok_json(
    app
      .patch(
        &admin,
        &format!("/users/{}", created.user.id),
        &serde_json::json!({"roles": ["referee"]}),
      )
      .await,
  )
  .await;
  assert_eq!(changed.roles, vec![Role::Referee]);
  assert_eq!(
    app.get(Some(&login.token), "/auth/me").await.status(),
    StatusCode::UNAUTHORIZED
  );

  let reset: OneTimePassword = ok_json(
    app
      .post(Some(&admin), &format!("/users/{}/reset-password", created.user.id), &())
      .await,
  )
  .await;
  assert_ne!(reset.password, created.password);
  assert_eq!(
    app.login("head-ref", &created.password).await.status(),
    StatusCode::UNAUTHORIZED
  );
  assert_eq!(app.login("head-ref", &reset.password).await.status(), StatusCode::OK);

  let disabled: UserSummary = ok_json(
    app
      .patch(
        &admin,
        &format!("/users/{}", created.user.id),
        &serde_json::json!({"disabled": true}),
      )
      .await,
  )
  .await;
  assert!(disabled.disabled);
  assert_eq!(
    app.login("head-ref", &reset.password).await.status(),
    StatusCode::UNAUTHORIZED
  );

  // The only admin cannot lock themselves out.
  let users: Vec<UserSummary> = ok_json(app.get(Some(&admin), "/users").await).await;
  let me = users.iter().find(|u| u.username == "admin").unwrap();
  let res = app
    .patch(
      &admin,
      &format!("/users/{}", me.id),
      &serde_json::json!({"roles": ["judge"]}),
    )
    .await;
  assert_eq!(error_code(res).await.1, "user.self_lockout");
}

#[tokio::test]
async fn keys_bind_to_tables_and_pods() {
  let app = TestApp::spawn().await;
  let admin = app.admin_token().await;
  let event = app.active_event(&admin, "SET-06").await;
  let table: GameTable = ok_json(
    app
      .post(
        Some(&admin),
        &format!("/events/{}/tables", event.id),
        &serde_json::json!({"name": "Red"}),
      )
      .await,
  )
  .await;
  let keys = format!("/events/{}/keys", event.id);

  let wrong_role = app
    .post(
      Some(&admin),
      &keys,
      &serde_json::json!({"label": "x", "role": "judge", "table_id": table.id}),
    )
    .await;
  assert_eq!(error_code(wrong_role).await.1, "key.invalid_binding");
  let other = app.create_event(&admin, "SET-07").await;
  let other_table: GameTable = ok_json(
    app
      .post(
        Some(&admin),
        &format!("/events/{}/tables", other.id),
        &serde_json::json!({"name": "Red"}),
      )
      .await,
  )
  .await;
  let wrong_event = app
    .post(
      Some(&admin),
      &keys,
      &serde_json::json!({"label": "x", "role": "referee", "table_id": other_table.id}),
    )
    .await;
  assert_eq!(error_code(wrong_event).await.1, "key.invalid_binding");

  let created: CreatedAccessKey = ok_json(
    app
      .post(
        Some(&admin),
        &keys,
        &serde_json::json!({"label": "Red table", "role": "referee", "table_id": table.id}),
      )
      .await,
  )
  .await;
  assert_eq!(created.summary.table_id, Some(table.id));
  let login: AuthResponse = ok_json(
    app
      .post(None, "/auth/key", &serde_json::json!({"key": created.key}))
      .await,
  )
  .await;
  assert!(
    matches!(login.identity.principal, Principal::Key { table_id: Some(t), .. } if t == table.id),
    "the device learns its table"
  );

  // Archiving the event revokes its keys.
  let archived: EventSummary = ok_json(
    app
      .post(Some(&admin), &format!("/events/{}/archive", event.id), &())
      .await,
  )
  .await;
  assert_eq!(archived.status, tms_core::dto::EventStatus::Archived);
  assert_eq!(
    app.get(Some(&login.token), "/auth/me").await.status(),
    StatusCode::UNAUTHORIZED
  );
  let listed: Vec<AccessKeySummary> = ok_json(app.get(Some(&admin), &keys).await).await;
  assert!(listed.iter().all(|k| k.revoked_at.is_some()));
}

#[tokio::test]
async fn audit_log_records_changes() {
  let app = TestApp::spawn().await;
  let admin = app.admin_token().await;
  let event = app.active_event(&admin, "SET-08").await;
  app
    .post(Some(&admin), &format!("/events/{}/teams", event.id), &team("1", "One"))
    .await;

  let entries: Vec<AuditEntry> = ok_json(app.get(Some(&admin), &format!("/audit?event_id={}", event.id)).await).await;
  let actions: Vec<&str> = entries.iter().map(|e| e.action.as_str()).collect();
  assert_eq!(
    actions,
    vec!["team.create", "event.activate", "event.create"],
    "newest first"
  );
  assert!(entries.iter().all(|e| e.actor == "user:admin"));

  let page: Vec<AuditEntry> = ok_json(
    app
      .get(
        Some(&admin),
        &format!("/audit?event_id={}&limit=1&before={}", event.id, entries[0].id),
      )
      .await,
  )
  .await;
  assert_eq!(page.len(), 1);
  assert_eq!(page[0].action, "event.activate");
}

#[tokio::test]
async fn timetable_blocks_use_event_local_time() {
  let app = TestApp::spawn().await;
  let admin = app.admin_token().await;
  let event = app.active_event(&admin, "SET-09").await;
  let path = format!("/events/{}/blocks", event.id);

  // Sydney is UTC+11 in November: 12:30 local is 01:30 UTC.
  let lunch = serde_json::json!({"kind": "break", "name": "Lunch", "starts_local": "2026-11-14T12:30:00", "ends_local": "2026-11-14T13:15:00"});
  let block: tms_core::model::ScheduleBlock = ok_json(app.post(Some(&admin), &path, &lunch).await).await;
  assert_eq!(block.starts_at.to_rfc3339(), "2026-11-14T01:30:00+00:00");

  let backwards = serde_json::json!({"kind": "break", "name": "Lunch", "starts_local": "2026-11-14T13:00:00", "ends_local": "2026-11-14T12:00:00"});
  assert_eq!(
    error_code(app.post(Some(&admin), &path, &backwards).await).await.1,
    "block.invalid_times"
  );

  let renamed = serde_json::json!({"kind": "ceremony", "name": "Opening", "starts_local": "2026-11-14T08:30:00", "ends_local": "2026-11-14T09:00:00"});
  let updated: tms_core::model::ScheduleBlock =
    ok_json(app.patch(&admin, &format!("/blocks/{}", block.id), &renamed).await).await;
  assert_eq!(
    (updated.name.as_str(), updated.kind),
    ("Opening", tms_core::model::BlockKind::Ceremony)
  );
  assert_eq!(
    app.delete(&admin, &format!("/blocks/{}", block.id)).await.status(),
    StatusCode::NO_CONTENT
  );
}
