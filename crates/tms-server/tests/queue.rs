//! Integrated queueing: queuers call teams, referees take them at the table, the timer waits for them, and every
//! change is audited.

mod common;

use common::{TestApp, error_code, ok_json, twelve_team_schedule};
use reqwest::StatusCode;
use tms_core::dto::{AuditEntry, AuthResponse, CreateAccessKeyRequest, CreatedAccessKey, EventSummary};
use tms_core::game::{MatchTimer, RankingRow};
use tms_core::model::{GameMatch, MatchState, QueueState};
use tms_core::ws::{ClientMessage, ServerMessage, TopicItem};
use tms_core::{Role, Topic};
use uuid::Uuid;

struct Setup {
  app: TestApp,
  admin: String,
  hr: String,
  queuer: String,
  referee: String,
  event: EventSummary,
}

impl Setup {
  async fn new(code: &str) -> Self {
    let app = TestApp::spawn().await;
    let admin = app.admin_token().await;
    let event = app.active_event(&admin, code).await;
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
    app
      .create_user("hr", "hr-password-1", &[Role::HeadReferee], false)
      .await;
    app
      .create_user("queuer", "queuer-password-1", &[Role::Queuer], false)
      .await;
    let hr = ok_json::<AuthResponse>(app.login("hr", "hr-password-1").await)
      .await
      .token;
    let queuer = ok_json::<AuthResponse>(app.login("queuer", "queuer-password-1").await)
      .await
      .token;
    let key: CreatedAccessKey = ok_json(
      app
        .post(
          Some(&admin),
          &format!("/events/{}/keys", event.id),
          &CreateAccessKeyRequest {
            label: "Red table".into(),
            role: Role::Referee,
            table_id: None,
            pod_id: None,
            expires_at: None,
          },
        )
        .await,
    )
    .await;
    let referee = ok_json::<AuthResponse>(
      app
        .post(None, "/auth/key", &serde_json::json!({ "key": key.key }))
        .await,
    )
    .await
    .token;
    Self {
      app,
      admin,
      hr,
      queuer,
      referee,
      event,
    }
  }

  async fn matches(&self) -> Vec<GameMatch> {
    ok_json(
      self
        .app
        .get(Some(&self.admin), &format!("/events/{}/matches", self.event.id))
        .await,
    )
    .await
  }

  async fn act(&self, token: &str, slot: Uuid, action: &str) -> reqwest::Response {
    self
      .app
      .post(
        Some(token),
        &format!("/slots/{slot}/queue"),
        &serde_json::json!({ "action": action }),
      )
      .await
  }

  async fn ok(&self, token: &str, slot: Uuid, action: &str) -> QueueState {
    let m: GameMatch = ok_json(self.act(token, slot, action).await).await;
    m.slots.into_iter().find(|s| s.id == slot).unwrap().queue
  }

  async fn start(&self, body: serde_json::Value) -> reqwest::Response {
    self
      .app
      .post(Some(&self.hr), &format!("/events/{}/timer/start", self.event.id), &body)
      .await
  }
}

#[tokio::test]
async fn a_team_is_called_taken_to_the_table_and_the_timer_waits_for_it() {
  let s = Setup::new("Q-01").await;
  let m = s.matches().await[0].clone();
  let (red, blue) = (m.slots[0].id, m.slots[1].id);
  ok_json::<GameMatch>(s.app.post(Some(&s.hr), &format!("/matches/{}/stage", m.id), &()).await).await;

  assert_eq!(s.ok(&s.queuer, red, "call").await, QueueState::Called);
  assert_eq!(s.ok(&s.queuer, red, "on_way").await, QueueState::OnWay);
  assert_eq!(s.ok(&s.queuer, red, "wait").await, QueueState::Waiting);
  assert_eq!(s.ok(&s.referee, red, "at_table").await, QueueState::AtTable);
  assert_eq!(s.ok(&s.referee, red, "ready").await, QueueState::Ready);

  let (status, code) = error_code(s.start(serde_json::json!({})).await).await;
  assert_eq!((status, code.as_str()), (StatusCode::CONFLICT, "timer.not_ready"));

  // A team that just turned up goes straight to the table.
  assert_eq!(s.ok(&s.referee, blue, "at_table").await, QueueState::AtTable);
  assert_eq!(s.ok(&s.referee, blue, "ready").await, QueueState::Ready);
  let started: MatchTimer = ok_json(s.start(serde_json::json!({})).await).await;
  assert_eq!(started.match_ids, vec![m.id]);
  let running = s.matches().await.into_iter().find(|x| x.id == m.id).unwrap();
  assert!(running.slots.iter().all(|slot| slot.queue == QueueState::Running));

  ok_json::<MatchTimer>(
    s.app
      .post(Some(&s.hr), &format!("/events/{}/timer/end", s.event.id), &())
      .await,
  )
  .await;
  let done = s.matches().await.into_iter().find(|x| x.id == m.id).unwrap();
  assert!(done.slots.iter().all(|slot| slot.queue == QueueState::Done));

  // Every change is in the audit log with who made it.
  let audit: Vec<AuditEntry> = ok_json(
    s.app
      .get(
        Some(&s.admin),
        &format!("/audit?event_id={}&entity_type=slot", s.event.id),
      )
      .await,
  )
  .await;
  let actions: Vec<(String, String)> = audit
    .iter()
    .rev()
    .map(|e| (e.action.clone(), e.actor.clone()))
    .collect();
  assert_eq!(
    actions,
    [
      ("slot.call", "user:queuer"),
      ("slot.on_way", "user:queuer"),
      ("slot.wait", "user:queuer"),
      ("slot.at_table", "key:Red table"),
      ("slot.ready", "key:Red table"),
      ("slot.at_table", "key:Red table"),
      ("slot.ready", "key:Red table"),
    ]
    .map(|(a, b)| (a.to_owned(), b.to_owned()))
  );
}

#[tokio::test]
async fn roles_decide_who_moves_a_team() {
  let s = Setup::new("Q-02").await;
  let slot = s.matches().await[0].slots[0].id;

  assert_eq!(s.act(&s.referee, slot, "call").await.status(), StatusCode::FORBIDDEN);
  assert_eq!(s.act(&s.queuer, slot, "ready").await.status(), StatusCode::FORBIDDEN);
  assert_eq!(s.act(&s.queuer, slot, "scratch").await.status(), StatusCode::FORBIDDEN);
  assert_eq!(s.ok(&s.queuer, slot, "wait").await, QueueState::Waiting);
  let (status, code) = error_code(s.act(&s.queuer, slot, "call").await).await;
  assert_eq!((status, code.as_str()), (StatusCode::CONFLICT, "queue.invalid_state"));

  assert_eq!(s.ok(&s.queuer, slot, "undo").await, QueueState::NotCalled);
  assert_eq!(s.ok(&s.queuer, slot, "no_show").await, QueueState::NoShow);
  assert_eq!(
    s.act(&s.queuer, slot, "undo").await.status(),
    StatusCode::FORBIDDEN,
    "only the head referee undoes a no-show"
  );
  assert_eq!(s.ok(&s.hr, slot, "undo").await, QueueState::NotCalled);
  assert_eq!(s.ok(&s.hr, slot, "scratch").await, QueueState::Scratched);
}

#[tokio::test]
async fn a_no_show_lets_the_match_start_and_needs_no_scoresheet() {
  let s = Setup::new("Q-03").await;
  let matches = s.matches().await;
  let (m, next) = (&matches[0], &matches[1]);
  ok_json::<GameMatch>(s.app.post(Some(&s.hr), &format!("/matches/{}/stage", m.id), &()).await).await;
  s.ok(&s.queuer, m.slots[0].id, "no_show").await;
  s.ok(&s.referee, m.slots[1].id, "ready").await;
  ok_json::<MatchTimer>(s.start(serde_json::json!({ "countdown": false })).await).await;
  ok_json::<MatchTimer>(
    s.app
      .post(Some(&s.hr), &format!("/events/{}/timer/end", s.event.id), &())
      .await,
  )
  .await;

  let finished = s.matches().await.into_iter().find(|x| x.id == m.id).unwrap();
  assert_eq!(
    finished.slots[0].queue,
    QueueState::NoShow,
    "the timer leaves a no-show alone"
  );
  assert!(!finished.slots[0].needs_sheet());
  assert!(finished.slots[1].needs_sheet());

  // Only the team that played needs a sheet before the next match on these tables, so staging waits for it.
  let (status, code) = error_code(
    s.app
      .post(Some(&s.hr), &format!("/matches/{}/stage", next.id), &())
      .await,
  )
  .await;
  assert_eq!((status, code.as_str()), (StatusCode::CONFLICT, "match.unscored_tables"));

  let rankings: Vec<RankingRow> = ok_json(
    s.app
      .get(Some(&s.admin), &format!("/events/{}/rankings", s.event.id))
      .await,
  )
  .await;
  assert!(
    rankings.iter().all(|r| r.best.is_none()),
    "a no-show adds nothing to the ranking"
  );
}

#[tokio::test]
async fn the_head_referee_can_start_anyway_with_a_reason() {
  let s = Setup::new("Q-04").await;
  let m = s.matches().await[0].clone();
  ok_json::<GameMatch>(s.app.post(Some(&s.hr), &format!("/matches/{}/stage", m.id), &()).await).await;

  let (status, code) = error_code(s.start(serde_json::json!({ "force": true })).await).await;
  assert_eq!((status, code.as_str()), (StatusCode::BAD_REQUEST, "timer.force_reason"));
  s.app.create_user("mc", "emcee-password-1", &[Role::Emcee], false).await;
  let emcee = ok_json::<AuthResponse>(s.app.login("mc", "emcee-password-1").await)
    .await
    .token;
  let emcee_force = s
    .app
    .post(
      Some(&emcee),
      &format!("/events/{}/timer/start", s.event.id),
      &serde_json::json!({ "force": true, "reason": "go" }),
    )
    .await;
  assert_eq!(emcee_force.status(), StatusCode::FORBIDDEN);

  ok_json::<MatchTimer>(
    s.start(serde_json::json!({ "force": true, "reason": "Blue referee is on paper" }))
      .await,
  )
  .await;
  let audit: Vec<AuditEntry> = ok_json(
    s.app
      .get(
        Some(&s.admin),
        &format!("/audit?event_id={}&entity_type=event", s.event.id),
      )
      .await,
  )
  .await;
  let start = audit.iter().find(|e| e.action == "timer.start").unwrap();
  assert_eq!(start.data["reason"], "Blue referee is on paper");
  assert_eq!(start.data["not_ready"].as_array().unwrap().len(), 2);

  // An abort puts the teams back to ready, and a reset starts their queue again.
  ok_json::<MatchTimer>(
    s.app
      .post(Some(&s.hr), &format!("/events/{}/timer/abort", s.event.id), &())
      .await,
  )
  .await;
  let aborted = s.matches().await.into_iter().find(|x| x.id == m.id).unwrap();
  assert_eq!(aborted.state, MatchState::Staged);
  assert!(aborted.slots.iter().all(|slot| slot.queue == QueueState::Ready));
  ok_json::<GameMatch>(s.app.post(Some(&s.hr), &format!("/matches/{}/cancel", m.id), &()).await).await;
  let reset: GameMatch = ok_json(s.app.post(Some(&s.hr), &format!("/matches/{}/reset", m.id), &()).await).await;
  assert!(reset.slots.iter().all(|slot| slot.queue == QueueState::NotCalled));
}

#[tokio::test]
async fn the_head_referee_sees_which_station_devices_are_connected() {
  let s = Setup::new("Q-05").await;
  let mut hr_feed = s.app.ws_ready(Some(&s.hr)).await;
  hr_feed
    .send(&ClientMessage::SetSubscriptions {
      topics: vec![Topic::Presence],
    })
    .await;
  assert_eq!(
    hr_feed.recv().await,
    ServerMessage::Snapshot {
      topic: Topic::Presence,
      items: vec![]
    }
  );

  let station = s.app.ws_ready(Some(&s.referee)).await;
  match hr_feed.recv().await {
    ServerMessage::Upsert {
      item: TopicItem::Presence(p),
      ..
    } => assert_eq!(
      (p.label.as_str(), p.connections, p.role),
      ("Red table", 1, Role::Referee)
    ),
    other => panic!("expected the station to appear, got {other:?}"),
  }
  drop(station);
  assert!(matches!(
    hr_feed.recv().await,
    ServerMessage::Delete {
      topic: Topic::Presence,
      ..
    }
  ));

  // People logged in with a password are not stations, and queuers can't watch presence.
  let _person = s.app.ws_ready(Some(&s.queuer)).await;
  assert!(hr_feed.try_recv(std::time::Duration::from_millis(300)).await.is_none());
  let mut queuer_feed = s.app.ws_ready(Some(&s.queuer)).await;
  queuer_feed
    .send(&ClientMessage::SetSubscriptions {
      topics: vec![Topic::Presence],
    })
    .await;
  assert!(matches!(queuer_feed.recv().await, ServerMessage::Error { code, .. } if code == "ws.topic_forbidden"));
}
