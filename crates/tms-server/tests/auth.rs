mod common;

use common::{ADMIN_PASSWORD, TestApp, error_code, ok_json};
use reqwest::StatusCode;
use tms_core::Role;
use tms_core::dto::{AuthResponse, CreatedAccessKey, Identity, Principal};

#[tokio::test]
async fn wrong_password_and_unknown_user_look_the_same() {
  let app = TestApp::spawn().await;
  app.create_user("admin", ADMIN_PASSWORD, &[Role::Admin], false).await;

  let wrong = error_code(app.login("admin", "nope").await).await;
  let unknown = error_code(app.login("ghost", "nope").await).await;
  assert_eq!(wrong, (StatusCode::UNAUTHORIZED, "auth.invalid_credentials".into()));
  assert_eq!(unknown, wrong);
}

#[tokio::test]
async fn bootstrap_admin_must_change_password_first() {
  let app = TestApp::spawn().await;
  app.create_user("admin", "bootstrap-pw", &[Role::Admin], true).await;

  let auth: AuthResponse = ok_json(app.login("admin", "bootstrap-pw").await).await;
  assert!(auth.identity.must_change_password);
  assert_eq!(
    error_code(app.get(Some(&auth.token), "/events").await).await,
    (StatusCode::FORBIDDEN, "auth.password_change_required".into())
  );

  let short = serde_json::json!({"current_password": "bootstrap-pw", "new_password": "short"});
  assert_eq!(
    error_code(app.post(Some(&auth.token), "/auth/password", &short).await)
      .await
      .1,
    "auth.password_too_short"
  );

  let change = serde_json::json!({"current_password": "bootstrap-pw", "new_password": "a-better-password"});
  let fresh: AuthResponse = ok_json(app.post(Some(&auth.token), "/auth/password", &change).await).await;
  assert!(!fresh.identity.must_change_password);

  // The old token is cut off by the password change; the one returned with it works.
  assert_eq!(
    app.get(Some(&auth.token), "/events").await.status(),
    StatusCode::UNAUTHORIZED
  );
  assert_eq!(app.get(Some(&fresh.token), "/events").await.status(), StatusCode::OK);
  assert_eq!(
    app.login("admin", "bootstrap-pw").await.status(),
    StatusCode::UNAUTHORIZED
  );
  assert_eq!(app.login("admin", "a-better-password").await.status(), StatusCode::OK);
}

#[tokio::test]
async fn logout_revokes_the_session() {
  let app = TestApp::spawn().await;
  let token = app.admin_token().await;
  assert_eq!(app.get(Some(&token), "/auth/me").await.status(), StatusCode::OK);
  assert_eq!(
    app.post(Some(&token), "/auth/logout", &()).await.status(),
    StatusCode::NO_CONTENT
  );
  assert_eq!(
    app.get(Some(&token), "/auth/me").await.status(),
    StatusCode::UNAUTHORIZED
  );
  assert_eq!(app.get(None, "/auth/me").await.status(), StatusCode::UNAUTHORIZED);
}

#[tokio::test]
async fn access_key_lifecycle() {
  let app = TestApp::spawn().await;
  let admin = app.admin_token().await;
  let event = app.create_event(&admin, "TEST-01").await;

  let created: CreatedAccessKey = ok_json(
    app
      .post(
        Some(&admin),
        &format!("/events/{}/keys", event.id),
        &serde_json::json!({"label": "Table 1", "role": "referee"}),
      )
      .await,
  )
  .await;
  assert!(created.key.starts_with("REF-"));
  assert_eq!(created.summary.roles, vec![Role::Referee]);

  // Lower case and spaces are tolerated.
  let typed = format!(" {} ", created.key.to_lowercase());
  let auth: AuthResponse = ok_json(app.post(None, "/auth/key", &serde_json::json!({"key": typed})).await).await;
  let me: Identity = ok_json(app.get(Some(&auth.token), "/auth/me").await).await;
  assert_eq!(me.roles, vec![Role::Referee]);
  assert!(
    matches!(me.principal, Principal::Key { ref label, event_id, .. } if label == "Table 1" && event_id == event.id)
  );

  // A referee key cannot do admin work.
  assert_eq!(
    app.get(Some(&auth.token), "/events").await.status(),
    StatusCode::FORBIDDEN
  );

  let revoke = app
    .post(Some(&admin), &format!("/keys/{}/revoke", created.summary.id), &())
    .await;
  assert_eq!(revoke.status(), StatusCode::OK);
  assert_eq!(
    app.get(Some(&auth.token), "/auth/me").await.status(),
    StatusCode::UNAUTHORIZED
  );
  assert_eq!(
    app
      .post(None, "/auth/key", &serde_json::json!({"key": created.key}))
      .await
      .status(),
    StatusCode::UNAUTHORIZED
  );

  let audit: i64 = sqlx::query_scalar("select count(*) from audit_log where action in ('key.create', 'key.revoke')")
    .fetch_one(&app.pool)
    .await
    .unwrap();
  assert_eq!(audit, 2);
}

#[tokio::test]
async fn malformed_keys_are_rejected_without_a_lookup() {
  let app = TestApp::spawn().await;
  for key in ["", "REF-123", "XYZ-ABCD-EFGH-JKMN"] {
    assert_eq!(
      app
        .post(None, "/auth/key", &serde_json::json!({"key": key}))
        .await
        .status(),
      StatusCode::UNAUTHORIZED
    );
  }
}

#[tokio::test]
async fn event_validation() {
  let app = TestApp::spawn().await;
  let admin = app.admin_token().await;
  app.create_event(&admin, "dup-01").await;

  let dup = serde_json::json!({"code": "DUP-01", "name": "x", "season_id": "bioglow_founders", "timezone": "UTC", "starts_on": "2026-01-01", "ends_on": "2026-01-01"});
  assert_eq!(
    error_code(app.post(Some(&admin), "/events", &dup).await).await,
    (StatusCode::CONFLICT, "conflict.duplicate".into())
  );

  let bad_code = serde_json::json!({"code": "a b", "name": "x", "season_id": "bioglow_founders", "timezone": "UTC", "starts_on": "2026-01-01", "ends_on": "2026-01-01"});
  assert_eq!(
    error_code(app.post(Some(&admin), "/events", &bad_code).await).await.1,
    "event.invalid"
  );

  let backwards = serde_json::json!({"code": "OK-02", "name": "x", "season_id": "bioglow_founders", "timezone": "UTC", "starts_on": "2026-01-02", "ends_on": "2026-01-01"});
  assert_eq!(
    error_code(app.post(Some(&admin), "/events", &backwards).await).await.1,
    "event.invalid_dates"
  );

  let bad_tz = serde_json::json!({"code": "OK-03", "name": "x", "season_id": "bioglow_founders", "timezone": "Mars/Base", "starts_on": "2026-01-01", "ends_on": "2026-01-01"});
  assert_eq!(
    error_code(app.post(Some(&admin), "/events", &bad_tz).await).await.1,
    "event.invalid_timezone"
  );
}

#[tokio::test]
async fn refresh_issues_a_new_token_with_current_data() {
  let app = TestApp::spawn().await;
  let token = app.admin_token().await;
  let refreshed: AuthResponse = ok_json(app.post(Some(&token), "/auth/refresh", &()).await).await;
  assert_ne!(refreshed.token, token);
  assert_eq!(refreshed.identity.roles, vec![Role::Admin]);
  assert_eq!(
    app.get(Some(&refreshed.token), "/auth/me").await.status(),
    StatusCode::OK
  );
  assert_eq!(
    app.post(None, "/auth/refresh", &()).await.status(),
    StatusCode::UNAUTHORIZED
  );
}

#[tokio::test]
async fn repeated_failures_are_rate_limited() {
  let app = TestApp::spawn().await;
  app.create_user("admin", ADMIN_PASSWORD, &[Role::Admin], false).await;
  for _ in 0..tms_server::auth::limiter::MAX_FAILURES {
    assert_eq!(app.login("admin", "wrong").await.status(), StatusCode::UNAUTHORIZED);
  }
  // Even the right password is refused while the address is throttled.
  assert_eq!(
    error_code(app.login("admin", ADMIN_PASSWORD).await).await,
    (StatusCode::TOO_MANY_REQUESTS, "auth.rate_limited".into())
  );
  let key = serde_json::json!({"key": "REF-AAAA-BBBB-CCCC"});
  assert_eq!(
    app.post(None, "/auth/key", &key).await.status(),
    StatusCode::TOO_MANY_REQUESTS
  );
}

#[tokio::test]
async fn tokens_with_a_forged_payload_are_rejected() {
  let app = TestApp::spawn().await;
  let token = app.admin_token().await;
  let mut parts: Vec<&str> = token.split('.').collect();
  // A payload claiming other data: the signature no longer matches it.
  parts[1] = "eyJzdWIiOiIwIiwicm9sZXMiOlsiYWRtaW4iXX0";
  let forged = parts.join(".");
  assert_eq!(
    app.get(Some(&forged), "/auth/me").await.status(),
    StatusCode::UNAUTHORIZED
  );
}
