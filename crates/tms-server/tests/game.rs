//! Robot game: staging, the match timer, scoresheets, review and ranking. Test servers run match timings 100 times
//! faster, so a 2:30 match lasts 1.5 s.

mod common;

use std::time::Duration;

use chrono::Utc;
use common::{TestApp, error_code, ok_json, twelve_team_schedule};
use reqwest::StatusCode;
use tms_core::Role;
use tms_core::Topic;
use tms_core::dto::{AuthResponse, CreateAccessKeyRequest, CreatedAccessKey, EventSummary};
use tms_core::game::{
  MatchState, MatchTimer, RankingRow, Scoresheet, ScoresheetDoc, ScoresheetFlag, ScoresheetStatus, SyncOutcome,
  SyncScoresheetsRequest, SyncScoresheetsResponse, TimerPhase,
};
use tms_core::model::{GameMatch, MatchKind, QueueState, Team};
use tms_core::ws::{ClientMessage, ServerMessage, TopicItem};
use tms_seasons::{Answer, BIOGLOW_FOUNDERS};
use uuid::Uuid;

struct Setup {
  app: TestApp,
  admin: String,
  hr: String,
  referee: String,
  event: EventSummary,
  matches: Vec<GameMatch>,
  teams: Vec<Team>,
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
    let hr = ok_json::<AuthResponse>(app.login("hr", "hr-password-1").await)
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
    let matches = ok_json(app.get(Some(&admin), &format!("/events/{}/matches", event.id)).await).await;
    let teams = ok_json(app.get(Some(&admin), &format!("/events/{}/teams", event.id)).await).await;
    Self {
      app,
      admin,
      hr,
      referee,
      event,
      matches,
      teams,
    }
  }

  fn team_number(&self, id: Option<Uuid>) -> String {
    self.teams.iter().find(|t| Some(t.id) == id).unwrap().number.clone()
  }

  async fn get_match(&self, id: Uuid) -> GameMatch {
    let all: Vec<GameMatch> = ok_json(
      self
        .app
        .get(Some(&self.admin), &format!("/events/{}/matches", self.event.id))
        .await,
    )
    .await;
    all.into_iter().find(|m| m.id == id).unwrap()
  }

  async fn timer(&self) -> MatchTimer {
    ok_json(
      self
        .app
        .get(Some(&self.admin), &format!("/events/{}/timer", self.event.id))
        .await,
    )
    .await
  }

  async fn stage(&self, id: Uuid) -> reqwest::Response {
    self
      .app
      .post(Some(&self.hr), &format!("/matches/{id}/stage"), &())
      .await
  }

  /// Marks every team in the staged matches ready (as the referees would), then starts the timer.
  async fn start(&self, countdown: bool) -> reqwest::Response {
    let all: Vec<GameMatch> = ok_json(
      self
        .app
        .get(Some(&self.admin), &format!("/events/{}/matches", self.event.id))
        .await,
    )
    .await;
    for m in all.iter().filter(|m| m.state == MatchState::Staged) {
      for slot in m
        .slots
        .iter()
        .filter(|s| s.team_id.is_some() && s.queue != QueueState::Ready)
      {
        ok_json::<GameMatch>(
          self
            .app
            .post(
              Some(&self.hr),
              &format!("/slots/{}/queue", slot.id),
              &serde_json::json!({ "action": "ready" }),
            )
            .await,
        )
        .await;
      }
    }
    self
      .app
      .post(
        Some(&self.hr),
        &format!("/events/{}/timer/start", self.event.id),
        &serde_json::json!({ "countdown": countdown }),
      )
      .await
  }

  /// Waits for the timer to reach `phase`, checking every 50 ms for up to 5 s.
  async fn wait_for(&self, phase: TimerPhase) -> MatchTimer {
    for _ in 0..100 {
      let timer = self.timer().await;
      if timer.phase == phase {
        return timer;
      }
      tokio::time::sleep(Duration::from_millis(50)).await;
    }
    panic!("timer never reached {phase:?}");
  }

  /// A valid sheet for one slot of a match, scoring 70 plus `extra` answers.
  fn sheet(&self, m: &GameMatch, slot: usize, extra: &[(&str, Answer)]) -> ScoresheetDoc {
    let mut answers = BIOGLOW_FOUNDERS.defaults();
    answers.insert("m15d".into(), Answer::Choice("mine".into()));
    for (id, answer) in extra {
      answers.insert((*id).into(), answer.clone());
    }
    let score = BIOGLOW_FOUNDERS.score(&answers).total;
    ScoresheetDoc {
      id: Uuid::now_v7(),
      event_id: self.event.id,
      event_code: self.event.code.clone(),
      season_id: BIOGLOW_FOUNDERS.id.into(),
      schema_version: BIOGLOW_FOUNDERS.schema_version,
      team_number: self.team_number(m.slots[slot].team_id),
      slot_id: Some(m.slots[slot].id),
      kind: m.kind,
      round: None,
      table_id: Some(m.slots[slot].table_id),
      referee_name: "Sam".into(),
      no_show: false,
      answers,
      score,
      gp: Some(3),
      gp_comment: String::new(),
      team_agreed: true,
      team_initials: "AB".into(),
      private_comment: String::new(),
      created_at: Utc::now(),
    }
  }

  async fn submit(&self, token: &str, docs: &[ScoresheetDoc]) -> Vec<SyncOutcome> {
    let response: SyncScoresheetsResponse = ok_json(
      self
        .app
        .post(
          Some(token),
          "/sync/scoresheets",
          &SyncScoresheetsRequest {
            documents: docs.to_vec(),
          },
        )
        .await,
    )
    .await;
    response.results.into_iter().map(|r| r.outcome).collect()
  }

  async fn rankings(&self) -> Vec<RankingRow> {
    ok_json(
      self
        .app
        .get(Some(&self.admin), &format!("/events/{}/rankings", self.event.id))
        .await,
    )
    .await
  }
}

const PUBLISHED: SyncOutcome = SyncOutcome::Accepted {
  status: ScoresheetStatus::Published,
};

#[tokio::test]
async fn a_full_match_from_stage_to_scoreboard() {
  let s = Setup::new("RG-01").await;
  assert_eq!(s.matches.len(), 18);
  let m = s.matches[0].clone();
  assert_eq!((m.state, m.slots.len()), (MatchState::Scheduled, 2));

  let mut ws = s.app.ws_ready(None).await;
  ws.send(&ClientMessage::SetSubscriptions {
    topics: vec![Topic::Timer, Topic::Rankings],
  })
  .await;
  ws.drain().await;

  let staged: GameMatch = ok_json(s.stage(m.id).await).await;
  assert_eq!(staged.state, MatchState::Staged);

  let started: MatchTimer = ok_json(s.start(true).await).await;
  assert_eq!(started.phase, TimerPhase::Countdown);
  assert_eq!(started.match_ids, vec![m.id]);
  assert_eq!(s.get_match(m.id).await.state, MatchState::Running);
  let (status, code) = error_code(s.start(false).await).await;
  assert_eq!((status, code.as_str()), (StatusCode::CONFLICT, "timer.running"));

  let ended = s.wait_for(TimerPhase::Ended).await;
  assert_eq!(ended.match_ids, vec![m.id]);
  let finished = s.get_match(m.id).await;
  assert_eq!(finished.state, MatchState::Finished);
  assert!(finished.is_unscored());

  // The live feed saw every phase in order.
  let mut phases = Vec::new();
  while let Some(message) = ws.try_recv(Duration::from_millis(200)).await {
    if let ServerMessage::Upsert {
      item: TopicItem::Timer(t),
      ..
    } = message
    {
      phases.push(t.phase);
    }
  }
  assert_eq!(
    phases,
    [
      TimerPhase::Countdown,
      TimerPhase::Running,
      TimerPhase::Endgame,
      TimerPhase::Ended
    ]
  );

  let red = s.sheet(&m, 0, &[("m08a", Answer::Bool(true))]);
  let blue = s.sheet(&m, 1, &[]);
  assert_eq!(
    s.submit(&s.referee, &[red.clone(), blue.clone()]).await,
    [PUBLISHED, PUBLISHED]
  );
  assert_eq!(
    s.submit(&s.referee, std::slice::from_ref(&red)).await,
    [SyncOutcome::Duplicate {
      status: ScoresheetStatus::Published
    }],
    "sending the same sheet again stores nothing new"
  );
  let scored = s.get_match(m.id).await;
  assert!(!scored.is_unscored());
  assert!(
    scored
      .slots
      .iter()
      .all(|slot| slot.sheet == Some(ScoresheetStatus::Published))
  );

  // The scoreboard reloads its ranking on the live feed.
  match ws.recv().await {
    ServerMessage::Snapshot {
      topic: Topic::Rankings,
      items,
    } => assert_eq!(items.len(), 12),
    other => panic!("expected a rankings snapshot, got {other:?}"),
  }
  let rankings = s.rankings().await;
  let red_team = m.slots[0].team_id.unwrap();
  assert_eq!(rankings[0].team_id, red_team);
  assert_eq!((rankings[0].rank, rankings[0].best), (1, Some(100)));
  assert_eq!(rankings[0].scores, [Some(100), None, None]);
  assert_eq!((rankings[1].rank, rankings[1].best), (2, Some(70)));
  assert!(rankings[2..].iter().all(|r| r.rank == 3 && r.best.is_none()));
}

#[tokio::test]
async fn second_sheet_for_a_round_waits_for_the_head_referee() {
  let s = Setup::new("RG-02").await;
  let m = s.matches[0].clone();
  let first = s.sheet(&m, 0, &[]);
  assert_eq!(s.submit(&s.referee, std::slice::from_ref(&first)).await, [PUBLISHED]);

  let second = s.sheet(&m, 0, &[("m13a", Answer::Bool(true))]);
  assert_eq!(
    s.submit(&s.referee, std::slice::from_ref(&second)).await,
    [SyncOutcome::Accepted {
      status: ScoresheetStatus::Submitted
    }]
  );
  let stored: Scoresheet = ok_json(s.app.get(Some(&s.hr), &format!("/scoresheets/{}", second.id)).await).await;
  assert_eq!(stored.flags, [ScoresheetFlag::DuplicateRound]);
  assert_eq!((stored.round, stored.kind), (1, MatchKind::Ranking));

  let referee_cannot_accept = s
    .app
    .post(Some(&s.referee), &format!("/scoresheets/{}/accept", second.id), &())
    .await;
  assert_eq!(referee_cannot_accept.status(), StatusCode::FORBIDDEN);

  let accepted: Scoresheet = ok_json(
    s.app
      .post(Some(&s.hr), &format!("/scoresheets/{}/accept", second.id), &())
      .await,
  )
  .await;
  assert_eq!(accepted.status, ScoresheetStatus::Published);
  assert_eq!(accepted.reviewed_by.as_deref(), Some("user:hr"));
  let replaced: Scoresheet = ok_json(s.app.get(Some(&s.hr), &format!("/scoresheets/{}", first.id)).await).await;
  assert_eq!(replaced.status, ScoresheetStatus::Superseded);
  assert_eq!(s.rankings().await[0].best, Some(100));

  let (status, code) = error_code(
    s.app
      .post(
        Some(&s.hr),
        &format!("/scoresheets/{}/reject", second.id),
        &serde_json::json!({}),
      )
      .await,
  )
  .await;
  assert_eq!(
    (status, code.as_str()),
    (StatusCode::BAD_REQUEST, "scoresheet.note_required")
  );
  let rejected: Scoresheet = ok_json(
    s.app
      .post(
        Some(&s.hr),
        &format!("/scoresheets/{}/reject", second.id),
        &serde_json::json!({ "note": "M13 was touching the robot" }),
      )
      .await,
  )
  .await;
  assert_eq!(rejected.status, ScoresheetStatus::Rejected);
  assert_eq!(rejected.review_note, "M13 was touching the robot");
  assert_eq!(
    s.rankings().await[0].best,
    None,
    "the superseded sheet does not come back on its own"
  );
}

#[tokio::test]
async fn head_referee_review_mode_holds_every_sheet() {
  let s = Setup::new("RG-03").await;
  let mut settings = s.event.settings.clone();
  settings.scoresheet_review = tms_core::model::ScoresheetReview::HeadRefereeReview;
  ok_json::<EventSummary>(
    s.app
      .patch(
        &s.admin,
        &format!("/events/{}", s.event.id),
        &serde_json::json!({
          "name": s.event.name, "season_id": s.event.season_id, "timezone": s.event.timezone,
          "starts_on": s.event.starts_on, "ends_on": s.event.ends_on, "settings": settings,
        }),
      )
      .await,
  )
  .await;
  let m = s.matches[0].clone();
  let doc = s.sheet(&m, 1, &[]);
  assert_eq!(
    s.submit(&s.referee, std::slice::from_ref(&doc)).await,
    [SyncOutcome::Accepted {
      status: ScoresheetStatus::Submitted
    }]
  );
  assert_eq!(
    s.get_match(m.id).await.slots[1].sheet,
    Some(ScoresheetStatus::Submitted)
  );
  assert!(s.rankings().await.iter().all(|r| r.best.is_none()));
  ok_json::<Scoresheet>(
    s.app
      .post(Some(&s.hr), &format!("/scoresheets/{}/accept", doc.id), &())
      .await,
  )
  .await;
  assert_eq!(s.rankings().await[0].best, Some(70));
}

#[tokio::test]
async fn bad_sheets_are_refused_with_reasons() {
  let s = Setup::new("RG-04").await;
  let m = s.matches[0].clone();

  let mut invalid = s.sheet(&m, 0, &[("m14a", Answer::Count(1)), ("m14b", Answer::Count(3))]);
  invalid.gp = Some(4);
  let mut unknown_team = s.sheet(&m, 0, &[]);
  unknown_team.team_number = "999".into();
  let mut wrong_team = s.sheet(&m, 0, &[]);
  wrong_team.team_number = s.team_number(m.slots[1].team_id);
  let mut no_round = s.sheet(&m, 0, &[]);
  no_round.slot_id = None;
  let mut other_event = s.sheet(&m, 0, &[]);
  other_event.event_id = Uuid::now_v7();
  let mut old_form = s.sheet(&m, 0, &[]);
  old_form.schema_version += 1;
  let mut recomputed = s.sheet(&m, 0, &[]);
  recomputed.score = 999;

  let outcomes = s
    .submit(
      &s.referee,
      &[
        invalid,
        unknown_team,
        wrong_team,
        no_round,
        other_event,
        old_form,
        recomputed.clone(),
      ],
    )
    .await;
  let SyncOutcome::Rejected { code, issues, .. } = &outcomes[0] else {
    panic!("{:?}", outcomes[0]);
  };
  assert_eq!(code, "scoresheet.invalid");
  let fields: Vec<&str> = issues.iter().map(|i| i.field.as_str()).collect();
  assert_eq!(
    fields,
    ["m14b", "m14a", "gp"],
    "errors, the seed warning, then the GP comment"
  );
  assert!(matches!(&outcomes[1], SyncOutcome::NeedsBinding { reason } if reason.contains("999")));
  assert!(matches!(&outcomes[2], SyncOutcome::NeedsBinding { .. }));
  assert!(matches!(&outcomes[3], SyncOutcome::NeedsBinding { reason } if reason.contains("round")));
  assert!(matches!(&outcomes[4], SyncOutcome::Rejected { code, .. } if code == "scoresheet.wrong_event"));
  assert!(matches!(&outcomes[5], SyncOutcome::Rejected { code, .. } if code == "scoresheet.old_form"));
  assert_eq!(
    outcomes[6],
    SyncOutcome::Accepted {
      status: ScoresheetStatus::Submitted
    },
    "a total that doesn't match the server's goes to review"
  );
  let stored: Scoresheet = ok_json(s.app.get(Some(&s.hr), &format!("/scoresheets/{}", recomputed.id)).await).await;
  assert_eq!(
    (stored.score, stored.flags.as_slice()),
    (70, &[ScoresheetFlag::ScoreRecomputed][..])
  );

  let (status, _) = error_code(
    s.app
      .post(
        Some(&s.hr),
        "/sync/scoresheets",
        &SyncScoresheetsRequest {
          documents: vec![s.sheet(&m, 0, &[]); 51],
        },
      )
      .await,
  )
  .await;
  assert_eq!(status, StatusCode::BAD_REQUEST);

  // Scoresheets are for referees: the public live feed can't read them.
  let mut ws = s.app.ws_ready(None).await;
  ws.send(&ClientMessage::SetSubscriptions {
    topics: vec![Topic::Scoresheets],
  })
  .await;
  assert!(matches!(ws.recv().await, ServerMessage::Error { code, .. } if code == "ws.topic_forbidden"));
  let mut referee_ws = s.app.ws_ready(Some(&s.referee)).await;
  referee_ws
    .send(&ClientMessage::SetSubscriptions {
      topics: vec![Topic::Scoresheets],
    })
    .await;
  assert!(matches!(
    referee_ws.recv().await,
    ServerMessage::Snapshot { topic: Topic::Scoresheets, items } if items.len() == 1
  ));
}

#[tokio::test]
async fn staging_rules() {
  let s = Setup::new("RG-05").await;
  let (m1, m2, m3) = (&s.matches[0], &s.matches[1], &s.matches[2]);

  let (status, code) = error_code(s.start(false).await).await;
  assert_eq!((status, code.as_str()), (StatusCode::CONFLICT, "timer.nothing_staged"));

  ok_json::<GameMatch>(s.stage(m1.id).await).await;
  let (status, code) = error_code(s.stage(m2.id).await).await;
  assert_eq!((status, code.as_str()), (StatusCode::CONFLICT, "match.table_in_use"));
  let unstaged: GameMatch = ok_json(
    s.app
      .post(Some(&s.hr), &format!("/matches/{}/unstage", m1.id), &())
      .await,
  )
  .await;
  assert_eq!(unstaged.state, MatchState::Scheduled);

  // Run match 1 and leave it unscored: match 2 on the same tables needs a reason to go ahead.
  ok_json::<GameMatch>(s.stage(m1.id).await).await;
  ok_json::<MatchTimer>(s.start(false).await).await;
  let (status, code) = error_code(
    s.app
      .post(Some(&s.hr), &format!("/matches/{}/cancel", m1.id), &())
      .await,
  )
  .await;
  assert_eq!((status, code.as_str()), (StatusCode::CONFLICT, "match.invalid_state"));
  ok_json::<MatchTimer>(
    s.app
      .post(Some(&s.hr), &format!("/events/{}/timer/end", s.event.id), &())
      .await,
  )
  .await;
  assert_eq!(s.get_match(m1.id).await.state, MatchState::Finished);

  let (status, code) = error_code(s.stage(m2.id).await).await;
  assert_eq!((status, code.as_str()), (StatusCode::CONFLICT, "match.unscored_tables"));
  let (status, _) = error_code(
    s.app
      .post(
        Some(&s.hr),
        &format!("/matches/{}/stage", m2.id),
        &serde_json::json!({ "force": true }),
      )
      .await,
  )
  .await;
  assert_eq!(status, StatusCode::BAD_REQUEST, "forcing needs a reason");
  let forced: GameMatch = ok_json(
    s.app
      .post(
        Some(&s.hr),
        &format!("/matches/{}/stage", m2.id),
        &serde_json::json!({ "force": true, "reason": "Red table sheet is on paper" }),
      )
      .await,
  )
  .await;
  assert_eq!(forced.state, MatchState::Staged);

  let cancelled: GameMatch = ok_json(
    s.app
      .post(Some(&s.admin), &format!("/matches/{}/cancel", m3.id), &())
      .await,
  )
  .await;
  assert_eq!(cancelled.state, MatchState::Cancelled);
  let reset: GameMatch = ok_json(s.app.post(Some(&s.hr), &format!("/matches/{}/reset", m3.id), &()).await).await;
  assert_eq!(reset.state, MatchState::Scheduled);

  let referee = s
    .app
    .post(Some(&s.referee), &format!("/matches/{}/stage", m3.id), &())
    .await;
  assert_eq!(referee.status(), StatusCode::FORBIDDEN);
}

#[tokio::test]
async fn abort_then_restart_cannot_double_fire() {
  let s = Setup::new("RG-06").await;
  let m = &s.matches[0];
  ok_json::<GameMatch>(s.stage(m.id).await).await;
  ok_json::<MatchTimer>(s.start(false).await).await;
  tokio::time::sleep(Duration::from_millis(500)).await;
  let aborted: MatchTimer = ok_json(
    s.app
      .post(Some(&s.hr), &format!("/events/{}/timer/abort", s.event.id), &())
      .await,
  )
  .await;
  assert_eq!(aborted.phase, TimerPhase::Aborted);
  assert_eq!(
    s.get_match(m.id).await.state,
    MatchState::Staged,
    "an aborted match can run again"
  );

  ok_json::<MatchTimer>(s.start(false).await).await;
  // The first run would have ended 1.5 s after it started. Past that point, the second run is still going.
  tokio::time::sleep(Duration::from_millis(1_200)).await;
  let timer = s.timer().await;
  assert!(timer.phase.is_live(), "{:?}", timer.phase);
  assert_eq!(s.get_match(m.id).await.state, MatchState::Running);

  s.wait_for(TimerPhase::Ended).await;
  assert_eq!(s.get_match(m.id).await.state, MatchState::Finished);
}

#[tokio::test]
async fn a_restarted_server_resumes_or_finishes_the_timer() {
  let s = Setup::new("RG-07").await;
  let (overdue, live) = (&s.matches[0], &s.matches[2]);
  sqlx::query("update game_matches set state = 'running' where id = any($1)")
    .bind(vec![overdue.id, live.id])
    .execute(&s.app.pool)
    .await
    .unwrap();

  // A run that should have ended while the server was down ends as soon as the server starts.
  sqlx::query(
    "insert into match_timers (event_id, run_id, phase, starts_at, countdown_ms, duration_ms, endgame_ms, match_ids)
     values ($1, $2, 'running', now() - interval '10 minutes', 0, 1500, 300, $3)",
  )
  .bind(s.event.id)
  .bind(Uuid::now_v7())
  .bind(vec![overdue.id])
  .execute(&s.app.pool)
  .await
  .unwrap();
  let _restarted = tms_server::AppState::with_timer_speedup(s.app.pool.clone(), 100)
    .await
    .unwrap();
  let timer = s.wait_for(TimerPhase::Ended).await;
  assert_eq!(timer.match_ids, vec![overdue.id]);
  assert_eq!(s.get_match(overdue.id).await.state, MatchState::Finished);

  // A run still in progress carries on to its end.
  sqlx::query(
    "update match_timers set run_id = $2, phase = 'running', starts_at = now(), match_ids = $3 where event_id = $1",
  )
  .bind(s.event.id)
  .bind(Uuid::now_v7())
  .bind(vec![live.id])
  .execute(&s.app.pool)
  .await
  .unwrap();
  let _restarted_again = tms_server::AppState::with_timer_speedup(s.app.pool.clone(), 100)
    .await
    .unwrap();
  tokio::time::sleep(Duration::from_millis(300)).await;
  assert_eq!(s.get_match(live.id).await.state, MatchState::Running);
  s.wait_for(TimerPhase::Ended).await;
  assert_eq!(s.get_match(live.id).await.state, MatchState::Finished);
}
