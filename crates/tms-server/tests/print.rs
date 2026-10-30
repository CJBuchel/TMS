//! Printables render to PDF for the people allowed to print them.

mod common;

use common::{TestApp, ok_json, twelve_team_schedule};
use reqwest::StatusCode;
use tms_core::Role;
use tms_core::dto::AuthResponse;

const ALL: [&str; 8] = [
  "team-schedules",
  "match-schedule",
  "judging-schedule",
  "table-signs",
  "pod-signs",
  "scoresheets",
  "rankings",
  "certificates",
];

#[tokio::test]
async fn every_printable_renders() {
  let app = TestApp::spawn().await;
  let admin = app.admin_token().await;
  let event = app.active_event(&admin, "PRN-01").await;
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
  for name in ALL {
    let res = app
      .get(Some(&admin), &format!("/events/{}/print/{name}.pdf", event.id))
      .await;
    assert_eq!(res.status(), StatusCode::OK, "{name}");
    assert_eq!(res.headers()["content-type"], "application/pdf", "{name}");
    let bytes = res.bytes().await.unwrap();
    assert!(bytes.starts_with(b"%PDF"), "{name}");
  }
  assert_eq!(
    app
      .get(Some(&admin), &format!("/events/{}/print/nope.pdf", event.id))
      .await
      .status(),
    StatusCode::NOT_FOUND
  );

  app
    .create_user("hr", "head-ref-password-1", &[Role::HeadReferee], false)
    .await;
  let hr = ok_json::<AuthResponse>(app.login("hr", "head-ref-password-1").await)
    .await
    .token;
  let status = |name: &'static str| {
    let (app, hr, id) = (&app, hr.clone(), event.id);
    async move {
      app
        .get(Some(&hr), &format!("/events/{id}/print/{name}.pdf"))
        .await
        .status()
    }
  };
  assert_eq!(
    status("scoresheets").await,
    StatusCode::OK,
    "head referees print scoresheets"
  );
  assert_eq!(
    status("certificates").await,
    StatusCode::FORBIDDEN,
    "but not certificates"
  );
  assert_eq!(status("team-schedules").await, StatusCode::FORBIDDEN);
}
