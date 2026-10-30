mod common;

use std::time::Duration;

use common::{TestApp, ok_json};
use tms_core::Topic;
use tms_core::dto::{AuthResponse, Banner, BannerSeverity, CreatedAccessKey, EventSummary};
use tms_core::ws::{ClientMessage, ServerMessage, TopicItem};

fn banner_body(message: &str) -> serde_json::Value {
  serde_json::json!({"severity": "warning", "message": message})
}

async fn active_event(app: &TestApp, admin: &str) -> EventSummary {
  let event = app.create_event(admin, "WS-01").await;
  ok_json(
    app
      .post(Some(admin), &format!("/events/{}/activate", event.id), &())
      .await,
  )
  .await
}

#[tokio::test]
async fn snapshot_on_subscribe_then_deltas() {
  let app = TestApp::spawn().await;
  let admin = app.admin_token().await;
  let event = active_event(&app, &admin).await;
  let existing: Banner = ok_json(
    app
      .post(
        Some(&admin),
        &format!("/events/{}/banners", event.id),
        &banner_body("first"),
      )
      .await,
  )
  .await;

  let mut ws = app.ws_ready(None).await;
  // Duplicates are fine: one snapshot per distinct topic.
  ws.send(&ClientMessage::SetSubscriptions {
    topics: vec![Topic::Banners, Topic::Banners, Topic::Event],
  })
  .await;
  let snapshots = [ws.recv().await, ws.recv().await];
  assert!(snapshots.contains(&ServerMessage::Snapshot {
    topic: Topic::Banners,
    items: vec![TopicItem::Banner(existing.clone())]
  }));
  assert!(snapshots.contains(&ServerMessage::Snapshot {
    topic: Topic::Event,
    items: vec![TopicItem::Event(event.clone())]
  }));
  assert_eq!(ws.drain().await, Vec::<ServerMessage>::new());

  let second: Banner = ok_json(
    app
      .post(
        Some(&admin),
        &format!("/events/{}/banners", event.id),
        &banner_body("second"),
      )
      .await,
  )
  .await;
  assert_eq!(
    ws.recv().await,
    ServerMessage::Upsert {
      topic: Topic::Banners,
      item: TopicItem::Banner(second.clone())
    }
  );
  assert_eq!(second.severity, BannerSeverity::Warning);

  app
    .post(Some(&admin), &format!("/banners/{}/clear", existing.id), &())
    .await;
  assert_eq!(
    ws.recv().await,
    ServerMessage::Delete {
      topic: Topic::Banners,
      id: existing.id
    }
  );
}

#[tokio::test]
async fn removed_topics_stop_and_readded_topics_resnapshot() {
  let app = TestApp::spawn().await;
  let admin = app.admin_token().await;
  let event = active_event(&app, &admin).await;

  let mut ws = app.ws_ready(None).await;
  ws.send(&ClientMessage::SetSubscriptions {
    topics: vec![Topic::Banners, Topic::Event],
  })
  .await;
  assert_eq!(ws.drain().await.len(), 2);

  // Dropping banners: no snapshot for the unchanged event topic, and banner changes are no longer forwarded.
  ws.send(&ClientMessage::SetSubscriptions {
    topics: vec![Topic::Event],
  })
  .await;
  app
    .post(
      Some(&admin),
      &format!("/events/{}/banners", event.id),
      &banner_body("unseen"),
    )
    .await;
  assert_eq!(ws.drain().await, Vec::<ServerMessage>::new());

  // Re-adding banners sends a fresh snapshot that includes what was missed.
  ws.send(&ClientMessage::SetSubscriptions {
    topics: vec![Topic::Event, Topic::Banners],
  })
  .await;
  match ws.drain().await.as_slice() {
    [
      ServerMessage::Snapshot {
        topic: Topic::Banners,
        items,
      },
    ] => assert_eq!(items.len(), 1),
    other => panic!("expected one banners snapshot, got {other:?}"),
  }
}

#[tokio::test]
async fn activating_another_event_resnapshots() {
  let app = TestApp::spawn().await;
  let admin = app.admin_token().await;
  let first = active_event(&app, &admin).await;
  let second = app.create_event(&admin, "WS-02").await;

  let mut ws = app.ws_ready(None).await;
  ws.send(&ClientMessage::SetSubscriptions {
    topics: vec![Topic::Event],
  })
  .await;
  assert_eq!(
    ws.recv().await,
    ServerMessage::Snapshot {
      topic: Topic::Event,
      items: vec![TopicItem::Event(first)]
    }
  );

  let activated: EventSummary = ok_json(
    app
      .post(Some(&admin), &format!("/events/{}/activate", second.id), &())
      .await,
  )
  .await;
  assert_eq!(
    ws.recv().await,
    ServerMessage::Snapshot {
      topic: Topic::Event,
      items: vec![TopicItem::Event(activated)]
    }
  );
}

#[tokio::test]
async fn handshake_rules() {
  let app = TestApp::spawn().await;
  let admin = app.admin_token().await;

  // Authenticated welcome carries roles.
  let mut ws = app.ws().await;
  ws.send(&ClientMessage::Hello {
    v: 1,
    token: Some(admin),
    client_build: "t".into(),
  })
  .await;
  assert!(matches!(ws.recv().await, ServerMessage::Welcome { roles, .. } if roles == vec![tms_core::Role::Admin]));

  // Bad token: error then close.
  let mut ws = app.ws().await;
  ws.send(&ClientMessage::Hello {
    v: 1,
    token: Some("bogus".into()),
    client_build: "t".into(),
  })
  .await;
  assert!(matches!(ws.recv().await, ServerMessage::Error { code, .. } if code == "auth.required"));
  assert!(ws.try_recv(Duration::from_secs(1)).await.is_none());

  // Wrong protocol version.
  let mut ws = app.ws().await;
  ws.send(&ClientMessage::Hello {
    v: 999,
    token: None,
    client_build: "t".into(),
  })
  .await;
  assert!(matches!(ws.recv().await, ServerMessage::Error { code, .. } if code == "ws.protocol_version"));

  // Unknown topic strings are reported, and the connection stays usable.
  let mut ws = app.ws_ready(None).await;
  ws.send_raw(r#"{"type":"set_subscriptions","topics":["nope"]}"#).await;
  assert!(matches!(ws.recv().await, ServerMessage::Error { code, .. } if code == "ws.bad_message"));
  assert_eq!(ws.drain().await, Vec::<ServerMessage>::new());
}

#[tokio::test]
async fn time_sync_echoes_client_time() {
  let app = TestApp::spawn().await;
  let mut ws = app.ws_ready(None).await;
  ws.send(&ClientMessage::TimeSync { client_ms: 42 }).await;
  let now = chrono::Utc::now().timestamp_millis();
  match ws.recv().await {
    ServerMessage::TimeSync {
      client_ms: 42,
      server_ms,
    } => assert!((server_ms - now).abs() < 2_000),
    other => panic!("unexpected {other:?}"),
  }
}

#[tokio::test]
async fn revoking_a_key_closes_its_live_connection() {
  let app = TestApp::spawn().await;
  let admin = app.admin_token().await;
  let event = app.create_event(&admin, "WS-03").await;
  let body = serde_json::json!({"label": "Table 2", "role": "referee"});
  let created: CreatedAccessKey = ok_json(
    app
      .post(Some(&admin), &format!("/events/{}/keys", event.id), &body)
      .await,
  )
  .await;
  let auth: AuthResponse = ok_json(
    app
      .post(None, "/auth/key", &serde_json::json!({"key": created.key}))
      .await,
  )
  .await;

  let mut referee = app.ws_ready(Some(&auth.token)).await;
  let mut bystander = app.ws_ready(Some(&admin)).await;
  app
    .post(Some(&admin), &format!("/keys/{}/revoke", created.summary.id), &())
    .await;

  assert!(matches!(referee.recv().await, ServerMessage::Error { code, .. } if code == "auth.revoked"));
  assert!(
    referee.try_recv(Duration::from_secs(1)).await.is_none(),
    "the connection closes"
  );
  assert_eq!(
    bystander.drain().await,
    Vec::<ServerMessage>::new(),
    "other logins are untouched"
  );
}

#[tokio::test]
async fn changing_password_logs_out_other_devices() {
  let app = TestApp::spawn().await;
  let token = app.admin_token().await;
  let mut other_device = app.ws_ready(Some(&token)).await;
  let change = serde_json::json!({"current_password": common::ADMIN_PASSWORD, "new_password": "brand-new-password"});
  assert_eq!(
    app.post(Some(&token), "/auth/password", &change).await.status(),
    reqwest::StatusCode::OK
  );
  assert!(matches!(other_device.recv().await, ServerMessage::Error { code, .. } if code == "auth.revoked"));
}
