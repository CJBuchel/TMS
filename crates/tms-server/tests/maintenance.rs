//! Maintenance the launcher does with the server stopped: password recovery and purging an event.

mod common;

use common::{ADMIN_PASSWORD, TestApp, ok_json, twelve_team_schedule};
use reqwest::StatusCode;
use tms_core::Role;
use tms_core::dto::AuthResponse;
use tms_server::maintenance;

#[tokio::test]
async fn a_locked_out_user_gets_a_one_time_password() {
  let app = TestApp::spawn().await;
  app.admin_token().await;
  sqlx::query("update users set disabled = true where username = 'admin'")
    .execute(&app.pool)
    .await
    .unwrap();
  assert_eq!(
    app.login("admin", ADMIN_PASSWORD).await.status(),
    StatusCode::UNAUTHORIZED
  );

  let password = maintenance::reset_password(&app.pool, " admin ", None)
    .await
    .unwrap()
    .expect("a one-time password");
  let auth: AuthResponse = ok_json(app.login("admin", &password).await).await;
  assert!(
    auth.identity.must_change_password,
    "the one-time password must be changed at login"
  );
  assert!(maintenance::reset_password(&app.pool, "nobody", None).await.is_err());

  let chosen = maintenance::reset_password(&app.pool, "admin", Some("known-to-me".into()))
    .await
    .unwrap();
  assert_eq!(chosen, None, "a chosen password is not shown back");
  let auth: AuthResponse = ok_json(app.login("admin", "known-to-me").await).await;
  assert!(!auth.identity.must_change_password, "a chosen password needs no change");
}

#[tokio::test]
async fn the_admin_user_starts_as_admin_and_the_launcher_can_always_set_its_password() {
  use tms_server::bootstrap::{AdminAccount, DEFAULT_PASSWORD, ensure_admin};
  let app = TestApp::spawn().await;

  assert_eq!(
    ensure_admin(&app.pool, None).await.unwrap(),
    AdminAccount::CreatedWithDefault
  );
  let auth: AuthResponse = ok_json(app.login("admin", DEFAULT_PASSWORD).await).await;
  assert!(
    !auth.identity.must_change_password,
    "the starting password is not forced to change"
  );
  assert_eq!(ensure_admin(&app.pool, None).await.unwrap(), AdminAccount::Unchanged);

  sqlx::query("update users set disabled = true where username = 'admin'")
    .execute(&app.pool)
    .await
    .unwrap();
  assert_eq!(
    ensure_admin(&app.pool, Some("from-the-launcher".into())).await.unwrap(),
    AdminAccount::PasswordSet
  );
  assert_eq!(
    app.login("admin", DEFAULT_PASSWORD).await.status(),
    StatusCode::UNAUTHORIZED
  );
  let auth: AuthResponse = ok_json(app.login("admin", "from-the-launcher").await).await;
  assert!(
    !auth.identity.must_change_password,
    "and re-enabled, with no change asked"
  );
  assert_eq!(
    ensure_admin(&app.pool, Some("from-the-launcher".into())).await.unwrap(),
    AdminAccount::Unchanged,
    "the same password again changes nothing, so logins stay"
  );
  assert_eq!(app.get(Some(&auth.token), "/auth/me").await.status(), StatusCode::OK);
}

#[tokio::test]
async fn purging_an_event_removes_everything_in_it() {
  let app = TestApp::spawn().await;
  let admin = app.admin_token().await;
  let keep = app.create_event(&admin, "KEEP-1").await;
  let event = app.active_event(&admin, "GONE-1").await;
  ok_json::<serde_json::Value>(
    app
      .post_text(
        &admin,
        &format!("/events/{}/import/tiab?commit=true", event.id),
        &twelve_team_schedule(),
      )
      .await,
  )
  .await;
  app.create_user("ref", "ref-password-1", &[Role::Referee], false).await;
  ok_json::<serde_json::Value>(
    app
      .post(
        Some(&admin),
        &format!("/events/{}/keys", event.id),
        &serde_json::json!({ "label": "Red", "role": "referee" }),
      )
      .await,
  )
  .await;
  // A scoresheet holds on to its team, which plain cascading would trip over.
  sqlx::query(
    "insert into scoresheets (id, event_id, event_code, season_id, schema_version, team_id, kind, round, submitted_by,
       status, score, answers, created_at)
     select gen_random_uuid(), $1, 'GONE-1', 'bioglow_founders', 1, id, 'ranking', 1, 'test', 'published', 70, '{}', now()
     from teams where event_id = $1 limit 1",
  )
  .bind(event.id)
  .execute(&app.pool)
  .await
  .unwrap();

  let wrong = maintenance::purge_event(&app.pool, event.id, "KEEP-1").await;
  assert!(wrong.unwrap_err().to_string().contains("GONE-1"));
  maintenance::purge_event(&app.pool, event.id, "gone-1").await.unwrap();

  let codes: Vec<String> = maintenance::event_list(&app.pool)
    .await
    .unwrap()
    .into_iter()
    .map(|e| e.code)
    .collect();
  assert_eq!(codes, [keep.code]);
  for table in [
    "teams",
    "game_matches",
    "match_slots",
    "scoresheets",
    "access_keys",
    "judging_sessions",
  ] {
    let left: i64 = sqlx::query_scalar(sqlx::AssertSqlSafe(format!("select count(*) from {table}")))
      .fetch_one(&app.pool)
      .await
      .unwrap();
    assert_eq!(left, 0, "{table}");
  }
  let audited: i64 =
    sqlx::query_scalar("select count(*) from audit_log where action = 'event.purge' and actor = 'launcher'")
      .fetch_one(&app.pool)
      .await
      .unwrap();
  assert_eq!(audited, 1);
}
