//! Judging: pod timers, the judging queue, rubrics and their review, the judge advisor's scores, deliberation and
//! the awards ceremony.

mod common;

use std::collections::BTreeMap;

use chrono::Utc;
use common::{TestApp, error_code, ok_json, twelve_team_schedule};
use reqwest::StatusCode;
use tms_core::deliberation::{
  AdvancementRequest, AssignRequest, Award, AwardKind, AwardPatch, Ceremony, Deliberation, Hundredths, NewAward,
  TeamScores,
};
use tms_core::dto::{AuthResponse, EventSummary};
use tms_core::game::SyncOutcome;
use tms_core::judging::{
  Feedback, Nomination, PodTimer, Rubric, RubricDoc, RubricStatus, SyncRubricsRequest, SyncRubricsResponse,
};
use tms_core::model::{JudgingSession, QueueState};
use tms_core::ws::{ClientMessage, ServerMessage, TopicItem};
use tms_core::{Role, Topic};
use tms_seasons::BIOGLOW_FOUNDERS;
use uuid::Uuid;

struct Setup {
  app: TestApp,
  admin: String,
  judge: String,
  advisor: String,
  queuer: String,
  event: EventSummary,
  sessions: Vec<JudgingSession>,
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
    let mut tokens = Vec::new();
    for (name, role) in [
      ("judge", Role::Judge),
      ("advisor", Role::JudgeAdvisor),
      ("queuer", Role::Queuer),
    ] {
      app.create_user(name, "judging-password-1", &[role], false).await;
      tokens.push(
        ok_json::<AuthResponse>(app.login(name, "judging-password-1").await)
          .await
          .token,
      );
    }
    let sessions = ok_json(
      app
        .get(Some(&admin), &format!("/events/{}/judging-sessions", event.id))
        .await,
    )
    .await;
    let [judge, advisor, queuer] = <[String; 3]>::try_from(tokens).unwrap();
    Self {
      app,
      admin,
      judge,
      advisor,
      queuer,
      event,
      sessions,
    }
  }

  fn team_number(session: usize) -> String {
    // The schedule judges team n in session n.
    (session + 1).to_string()
  }

  fn rubric(&self, session: usize, level: u8) -> RubricDoc {
    let rows = BIOGLOW_FOUNDERS
      .rubrics
      .iter()
      .flat_map(tms_seasons::rubric::Rubric::rows);
    let scores: BTreeMap<String, u8> = rows.map(|r| (r.id.to_owned(), level)).collect();
    let exceeds_comments = if level == 4 {
      scores.keys().map(|k| (k.clone(), "Outstanding".to_owned())).collect()
    } else {
      BTreeMap::new()
    };
    RubricDoc {
      id: Uuid::now_v7(),
      event_id: self.event.id,
      event_code: self.event.code.clone(),
      season_id: BIOGLOW_FOUNDERS.id.into(),
      schema_version: BIOGLOW_FOUNDERS.schema_version,
      team_number: Self::team_number(session),
      slot_id: Some(self.sessions[session].slots[0].id),
      pod_id: Some(self.sessions[session].slots[0].pod_id),
      judge_names: "Ana, Ben".into(),
      scores,
      exceeds_comments,
      feedback: Feedback {
        core_values_great: "Everyone spoke".into(),
        ..Feedback::default()
      },
      nominations: vec![Nomination::Motivate],
      created_at: Utc::now(),
    }
  }

  async fn sync(&self, docs: &[RubricDoc]) -> Vec<SyncOutcome<RubricStatus>> {
    let response: SyncRubricsResponse = ok_json(
      self
        .app
        .post(
          Some(&self.judge),
          "/sync/rubrics",
          &SyncRubricsRequest {
            documents: docs.to_vec(),
          },
        )
        .await,
    )
    .await;
    response.results.into_iter().map(|r| r.outcome).collect()
  }

  async fn timer(&self, action: &str, body: serde_json::Value) -> reqwest::Response {
    let pod = self.sessions[0].slots[0].pod_id;
    self
      .app
      .post(Some(&self.judge), &format!("/pods/{pod}/timer/{action}"), &body)
      .await
  }

  async fn slot_state(&self, session: usize) -> QueueState {
    let all: Vec<JudgingSession> = ok_json(
      self
        .app
        .get(
          Some(&self.admin),
          &format!("/events/{}/judging-sessions", self.event.id),
        )
        .await,
    )
    .await;
    all[session].slots[0].queue
  }

  /// A judging queue action on the first session's slot.
  async fn act(&self, token: &str, action: &str) -> reqwest::Response {
    let slot = self.sessions[0].slots[0].id;
    self
      .app
      .post(
        Some(token),
        &format!("/judging-slots/{slot}/queue"),
        &serde_json::json!({ "action": action }),
      )
      .await
  }
}

#[tokio::test]
async fn a_session_runs_on_the_pod_timer_and_the_queue_follows() {
  let s = Setup::new("J-01").await;
  ok_json::<JudgingSession>(s.act(&s.queuer, "call").await).await;
  ok_json::<JudgingSession>(s.act(&s.queuer, "wait").await).await;
  assert_eq!(
    s.act(&s.queuer, "at_table").await.status(),
    StatusCode::FORBIDDEN,
    "judges take a team in"
  );
  ok_json::<JudgingSession>(s.act(&s.judge, "at_table").await).await;
  assert_eq!(s.slot_state(0).await, QueueState::AtTable);

  let (status, code) = error_code(s.timer("start", serde_json::json!({})).await).await;
  assert_eq!((status, code.as_str()), (StatusCode::CONFLICT, "pod_timer.invalid"));
  let started: PodTimer = ok_json(
    s.timer("start", serde_json::json!({ "session_id": s.sessions[0].id }))
      .await,
  )
  .await;
  assert_eq!((started.phase, started.phase_name()), (Some(0), "Welcome"));
  assert_eq!(s.slot_state(0).await, QueueState::Running);
  let extended: PodTimer = ok_json(s.timer("extend", serde_json::json!({})).await).await;
  assert_eq!(extended.phase_ms, 180_000);
  let next: PodTimer = ok_json(s.timer("next", serde_json::json!({})).await).await;
  assert_eq!(next.phase_name(), "Innovation Project presentation");
  let done: PodTimer = ok_json(s.timer("finish", serde_json::json!({})).await).await;
  assert_eq!(done.phase, None);
  assert_eq!(s.slot_state(0).await, QueueState::Done);

  let timers: Vec<PodTimer> = ok_json(
    s.app
      .get(Some(&s.queuer), &format!("/events/{}/pod-timers", s.event.id))
      .await,
  )
  .await;
  assert_eq!(timers.len(), 1);
}

#[tokio::test]
async fn rubrics_are_checked_accepted_and_reviewed() {
  let s = Setup::new("J-02").await;
  let first = s.rubric(0, 3);
  let mut missing = s.rubric(1, 3);
  missing.scores.remove("rd_iterate_testing");
  missing.scores.insert("ip_create_model".into(), 4);
  let mut wrong_team = s.rubric(2, 3);
  wrong_team.team_number = "1".into();
  let outcomes = s.sync(&[first.clone(), missing, wrong_team]).await;
  assert_eq!(
    outcomes[0],
    SyncOutcome::Accepted {
      status: RubricStatus::Accepted
    }
  );
  let SyncOutcome::Rejected { issues, .. } = &outcomes[1] else {
    panic!("{:?}", outcomes[1]);
  };
  let fields: Vec<&str> = issues.iter().map(|i| i.field.as_str()).collect();
  assert_eq!(fields, ["ip_create_model", "rd_iterate_testing"]);
  assert!(matches!(&outcomes[2], SyncOutcome::NeedsBinding { .. }));

  let stored: Rubric = ok_json(s.app.get(Some(&s.judge), &format!("/rubrics/{}", first.id)).await).await;
  assert_eq!(
    (stored.innovation_project, stored.robot_design, stored.core_values_rows),
    (30, 30, 30)
  );
  assert_eq!(stored.nominations, [Nomination::Motivate]);

  // A second rubric for the same team waits for the judge advisor.
  let second = s.rubric(0, 4);
  assert_eq!(
    s.sync(std::slice::from_ref(&second)).await,
    [SyncOutcome::Accepted {
      status: RubricStatus::Submitted
    }]
  );
  assert_eq!(
    s.app
      .post(Some(&s.judge), &format!("/rubrics/{}/accept", second.id), &())
      .await
      .status(),
    StatusCode::FORBIDDEN
  );
  let accepted: Rubric = ok_json(
    s.app
      .post(Some(&s.advisor), &format!("/rubrics/{}/accept", second.id), &())
      .await,
  )
  .await;
  assert_eq!(accepted.status, RubricStatus::Accepted);
  let old: Rubric = ok_json(s.app.get(Some(&s.judge), &format!("/rubrics/{}", first.id)).await).await;
  assert_eq!(old.status, RubricStatus::Superseded);

  let (status, code) = error_code(
    s.app
      .post(
        Some(&s.advisor),
        &format!("/rubrics/{}/reject", second.id),
        &serde_json::json!({}),
      )
      .await,
  )
  .await;
  assert_eq!(
    (status, code.as_str()),
    (StatusCode::BAD_REQUEST, "rubric.note_required")
  );

  // Rubrics are for judges: the public live feed can't read them.
  let mut public = s.app.ws_ready(None).await;
  public
    .send(&ClientMessage::SetSubscriptions {
      topics: vec![Topic::Rubrics],
    })
    .await;
  assert!(matches!(public.recv().await, ServerMessage::Error { code, .. } if code == "ws.topic_forbidden"));
  let mut judge = s.app.ws_ready(Some(&s.judge)).await;
  judge
    .send(&ClientMessage::SetSubscriptions {
      topics: vec![Topic::Rubrics],
    })
    .await;
  assert!(matches!(judge.recv().await, ServerMessage::Snapshot { items, .. } if items.len() == 2));
}

#[tokio::test]
async fn the_scores_page_ranks_every_area_and_champions() {
  let s = Setup::new("J-03").await;
  s.sync(&[s.rubric(0, 4), s.rubric(1, 3), s.rubric(2, 2)]).await;
  // Robot game: team 3 best, with Gracious Professionalism on every sheet.
  for (team, score, gp) in [("1", 100, 3), ("2", 150, 4), ("3", 300, 2)] {
    sqlx::query(
      "insert into scoresheets (id, event_id, event_code, season_id, schema_version, team_id, kind, round,
         submitted_by, status, score, gp, answers, created_at)
       select gen_random_uuid(), $1, 'J-03', 'bioglow_founders', 1, id, 'ranking', 1, 'test', 'published', $3, $4, '{}', now()
       from teams where event_id = $1 and number = $2",
    )
    .bind(s.event.id)
    .bind(team)
    .bind(score)
    .bind(gp)
    .execute(&s.app.pool)
    .await
    .unwrap();
  }
  assert_eq!(
    s.app
      .get(Some(&s.judge), &format!("/events/{}/judging-scores", s.event.id))
      .await
      .status(),
    StatusCode::FORBIDDEN,
    "the scores page is the judge advisor's"
  );
  let scores: Vec<TeamScores> = ok_json(
    s.app
      .get(Some(&s.advisor), &format!("/events/{}/judging-scores", s.event.id))
      .await,
  )
  .await;
  assert_eq!(scores.len(), 12);
  let team = |n: usize| &scores[n - 1];
  assert_eq!(
    team(1).core_values,
    Some(Hundredths(4300)),
    "Core Values rows plus the one GP score so far"
  );
  assert_eq!(team(2).gracious_professionalism, Some(Hundredths(400)));
  assert_eq!(
    (
      team(1).innovation_project_rank,
      team(3).robot_game_rank,
      team(4).innovation_project_rank
    ),
    (1, 1, 13)
  );
  assert_eq!((team(1).champions_rank, team(2).champions_rank), (1, 2));
}

#[tokio::test]
async fn judge_advisor_review_holds_every_rubric() {
  let s = Setup::new("J-04").await;
  let mut settings = s.event.settings.clone();
  settings.rubric_review = tms_core::model::RubricReview::JudgeAdvisorReview;
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
  assert_eq!(
    s.sync(&[s.rubric(0, 3)]).await,
    [SyncOutcome::Accepted {
      status: RubricStatus::Submitted
    }]
  );
  let sessions: Vec<JudgingSession> = ok_json(
    s.app
      .get(Some(&s.admin), &format!("/events/{}/judging-sessions", s.event.id))
      .await,
  )
  .await;
  assert_eq!(sessions[0].slots[0].rubric, Some(RubricStatus::Submitted));
}

impl Setup {
  /// Inserts a published ranking scoresheet for a team.
  async fn published(&self, team: &str, round: i32, score: i32, gp: i16) {
    sqlx::query(
      "insert into scoresheets (id, event_id, event_code, season_id, schema_version, team_id, kind, round,
         submitted_by, status, score, gp, answers, created_at)
       select gen_random_uuid(), $1, $5, 'bioglow_founders', 1, id, 'ranking', $3, 'test', 'published', $4, $6, '{}',
         now()
       from teams where event_id = $1 and number = $2",
    )
    .bind(self.event.id)
    .bind(team)
    .bind(round)
    .bind(score)
    .bind(&self.event.code)
    .bind(gp)
    .execute(&self.app.pool)
    .await
    .unwrap();
  }

  async fn deliberation(&self) -> Deliberation {
    ok_json(
      self
        .app
        .get(Some(&self.advisor), &format!("/events/{}/deliberation", self.event.id))
        .await,
    )
    .await
  }

  fn team_id(d: &Deliberation, number: usize) -> Uuid {
    // Deliberation lists teams in number order.
    d.teams[number - 1].team_id
  }

  async fn assign(&self, d: &Deliberation, kind: AwardKind, team: usize, place: u8, note: &str) -> reqwest::Response {
    let award = d.awards.iter().find(|a| a.kind == kind).unwrap();
    self
      .app
      .post(
        Some(&self.advisor),
        &format!("/awards/{}/winners", award.id),
        &AssignRequest {
          team_id: Self::team_id(d, team),
          place,
          note: note.into(),
        },
      )
      .await
  }
}

#[tokio::test]
async fn an_event_starts_with_the_required_awards() {
  let s = Setup::new("J-05").await;
  let path = format!("/events/{}/awards", s.event.id);
  let awards: Vec<Award> = ok_json(s.app.get(Some(&s.judge), &path).await).await;
  let mut kinds: Vec<AwardKind> = awards.iter().map(|a| a.kind).collect();
  kinds.sort();
  assert_eq!(
    kinds,
    [
      AwardKind::Champions,
      AwardKind::CoreValues,
      AwardKind::InnovationProject,
      AwardKind::RobotDesign,
      AwardKind::RobotPerformance,
      AwardKind::CoachMentor
    ]
  );
  assert_eq!(
    awards.last().unwrap().kind,
    AwardKind::Champions,
    "Champion's ends the ceremony"
  );

  let motivate = NewAward {
    kind: AwardKind::Motivate,
    name: String::new(),
    places: 2,
  };
  let added: Award = ok_json(s.app.post(Some(&s.admin), &path, &motivate).await).await;
  assert_eq!(added.name, "Motivate");
  assert_eq!(
    error_code(s.app.post(Some(&s.admin), &path, &motivate).await).await,
    (StatusCode::CONFLICT, "award.exists".into())
  );
  let too_many = NewAward {
    kind: AwardKind::Breakthrough,
    name: String::new(),
    places: 4,
  };
  assert_eq!(
    error_code(s.app.post(Some(&s.admin), &path, &too_many).await).await,
    (StatusCode::BAD_REQUEST, "award.places".into())
  );
  let local = NewAward {
    kind: AwardKind::Local,
    name: "Best Team Spirit".into(),
    places: 1,
  };
  ok_json::<Award>(s.app.post(Some(&s.admin), &path, &local).await).await;
  let champions = awards.iter().find(|a| a.kind == AwardKind::Champions).unwrap();
  assert_eq!(
    error_code(s.app.delete(&s.admin, &format!("/awards/{}", champions.id)).await).await,
    (StatusCode::CONFLICT, "award.required".into())
  );
  let finalists: Award = ok_json(
    s.app
      .patch(
        &s.admin,
        &format!("/awards/{}", champions.id),
        &AwardPatch {
          places: Some(3),
          ..AwardPatch::default()
        },
      )
      .await,
  )
  .await;
  assert_eq!(finalists.places, 3);
}

#[tokio::test]
async fn deliberation_allocates_in_order_with_one_judged_award_per_team() {
  let s = Setup::new("J-06").await;
  // Team 1 is strongest in judging, team 2 next; team 3 wins the robot game.
  s.sync(&[s.rubric(0, 4), s.rubric(1, 3), s.rubric(2, 2), s.rubric(3, 2)])
    .await;
  for (team, score) in [("1", 200), ("2", 150), ("3", 400), ("4", 100)] {
    s.published(team, 1, score, 3).await;
  }
  assert_eq!(
    s.app
      .get(Some(&s.judge), &format!("/events/{}/deliberation", s.event.id))
      .await
      .status(),
    StatusCode::FORBIDDEN,
    "deliberation is the judge advisor's"
  );
  let d = s.deliberation().await;
  assert_eq!(d.teams[0].champions_rank, 1);
  let champions = d.steps()[0];
  assert_eq!(d.top_candidate(champions), Some(Setup::team_id(&d, 1)));

  ok_json::<Deliberation>(s.assign(&d, AwardKind::Champions, 1, 1, "").await).await;
  let (status, code) = error_code(s.assign(&d, AwardKind::CoreValues, 1, 1, "").await).await;
  assert_eq!(
    (status, code.as_str()),
    (StatusCode::CONFLICT, "award.ineligible"),
    "one judged award per team"
  );
  assert_eq!(
    error_code(s.assign(&d, AwardKind::CoreValues, 3, 1, "").await).await,
    (StatusCode::BAD_REQUEST, "award.note_required".into()),
    "skipping the best-ranked eligible team needs a reason"
  );
  let d: Deliberation = ok_json(
    s.assign(&d, AwardKind::CoreValues, 3, 1, "Judges saw outstanding teamwork")
      .await,
  )
  .await;
  assert_eq!(
    d.winners
      .iter()
      .find(|w| w.note.contains("teamwork"))
      .unwrap()
      .assigned_by,
    "user:advisor"
  );
  ok_json::<Deliberation>(s.assign(&d, AwardKind::RobotPerformance, 3, 1, "").await).await;
  let d = s.deliberation().await;
  assert_eq!(
    d.teams_awarded(),
    2,
    "Robot Performance doesn't count as a judged award"
  );
  assert_eq!(
    error_code(s.assign(&d, AwardKind::InnovationProject, 3, 1, "").await).await,
    (StatusCode::CONFLICT, "award.ineligible".into())
  );
  let mut audit: Vec<serde_json::Value> = ok_json(
    s.app
      .get(Some(&s.admin), &format!("/audit?event_id={}&limit=50", s.event.id))
      .await,
  )
  .await;
  audit.retain(|e| e["action"] == "award.assign");
  assert_eq!(audit.len(), 3);
}

#[tokio::test]
async fn finalizing_locks_deliberation_and_starts_the_ceremony() {
  let s = Setup::new("J-07").await;
  ok_json::<EventSummary>(
    s.app
      .patch(
        &s.admin,
        &format!("/events/{}", s.event.id),
        &serde_json::json!({
          "name": s.event.name, "season_id": s.event.season_id, "timezone": s.event.timezone,
          "starts_on": s.event.starts_on, "ends_on": s.event.ends_on,
          "settings": { "advancement_slots": 1 }
        }),
      )
      .await,
  )
  .await;
  s.sync(&[s.rubric(0, 3), s.rubric(1, 2)]).await;
  let d = s.deliberation().await;
  assert_eq!(d.advancement_slots, 1);
  ok_json::<Deliberation>(s.assign(&d, AwardKind::Champions, 1, 1, "").await).await;
  ok_json::<Deliberation>(s.assign(&d, AwardKind::CoreValues, 2, 1, "").await).await;
  let advancement = format!("/events/{}/advancement", s.event.id);
  assert_eq!(
    error_code(
      s.app
        .post(
          Some(&s.advisor),
          &advancement,
          &AdvancementRequest {
            team_ids: vec![Setup::team_id(&d, 1), Setup::team_id(&d, 2)],
          }
        )
        .await
    )
    .await,
    (StatusCode::BAD_REQUEST, "advancement.too_many".into())
  );
  ok_json::<Deliberation>(
    s.app
      .post(
        Some(&s.advisor),
        &advancement,
        &AdvancementRequest {
          team_ids: vec![Setup::team_id(&d, 1)],
        },
      )
      .await,
  )
  .await;

  let mut screen = s.app.ws_ready(None).await;
  screen
    .send(&ClientMessage::SetSubscriptions {
      topics: vec![Topic::Ceremony],
    })
    .await;
  let ceremony = |m: ServerMessage| match m {
    ServerMessage::Snapshot { items, .. } => match items.into_iter().next() {
      Some(TopicItem::Ceremony(c)) => c,
      other => panic!("expected the ceremony, got {other:?}"),
    },
    other => panic!("expected a snapshot, got {other:?}"),
  };
  assert_eq!(
    ceremony(screen.recv().await).total,
    0,
    "nothing until deliberation is finalized"
  );
  let ceremony_path = format!("/events/{}/ceremony/next", s.event.id);
  assert_eq!(
    error_code(s.app.post(Some(&s.advisor), &ceremony_path, &()).await).await,
    (StatusCode::CONFLICT, "ceremony.not_finalized".into())
  );

  let finalized: Deliberation = ok_json(
    s.app
      .post(
        Some(&s.advisor),
        &format!("/events/{}/deliberation/finalize", s.event.id),
        &(),
      )
      .await,
  )
  .await;
  assert!(finalized.finalized.is_some());
  let after = ceremony(screen.recv().await);
  assert_eq!(
    (after.total, after.shown, after.slides.len()),
    (3, 0, 0),
    "two awards and advancement, none shown"
  );
  assert_eq!(
    error_code(s.assign(&d, AwardKind::RobotDesign, 2, 1, "").await).await,
    (StatusCode::CONFLICT, "deliberation.finalized".into())
  );
  let late = s.sync(&[s.rubric(2, 3)]).await;
  assert!(
    matches!(&late[0], SyncOutcome::Rejected { code, .. } if code == "rubric.finalized"),
    "{late:?}"
  );

  ok_json::<Ceremony>(s.app.post(Some(&s.advisor), &ceremony_path, &()).await).await;
  let first = ceremony(screen.recv().await);
  assert_eq!(first.slides.len(), 1);
  assert_eq!(
    first.slides[0].title, "Core Values",
    "the ceremony runs in ceremony order"
  );
  assert_eq!(first.slides[0].winners[0].team_number, "2");

  assert_eq!(
    s.app
      .post(
        Some(&s.advisor),
        &format!("/events/{}/deliberation/reopen", s.event.id),
        &()
      )
      .await
      .status(),
    StatusCode::FORBIDDEN,
    "only an admin reopens"
  );
  ok_json::<Deliberation>(
    s.app
      .post(
        Some(&s.admin),
        &format!("/events/{}/deliberation/reopen", s.event.id),
        &(),
      )
      .await,
  )
  .await;
  assert_eq!(ceremony(screen.recv().await).total, 0);
}

#[tokio::test]
async fn exports_follow_the_judging_spreadsheet() {
  let s = Setup::new("J-08").await;
  s.sync(&[s.rubric(0, 3), s.rubric(1, 2)]).await;
  s.published("1", 1, 120, 3).await;
  s.published("1", 2, 180, 4).await;
  let path = |name: &str| format!("/events/{}/exports/{name}.csv", s.event.id);
  assert_eq!(
    s.app.get(Some(&s.judge), &path("results")).await.status(),
    StatusCode::FORBIDDEN
  );
  let text = |res: reqwest::Response| async move {
    assert!(res.status().is_success());
    res.text().await.unwrap().trim_start_matches('\u{feff}').to_owned()
  };
  let results = text(s.app.get(Some(&s.advisor), &path("results")).await).await;
  let mut lines = results.lines();
  assert!(
    lines
      .next()
      .unwrap()
      .starts_with("Team Number,Team Name,Robot Game Score 1")
  );
  assert!(
    lines
      .next()
      .unwrap()
      .starts_with("1,Team 1,120,180,,,,180,1,1,1,1,4,1,"),
    "{results}"
  );
  let robot_game = text(s.app.get(Some(&s.advisor), &path("robot-game")).await).await;
  assert!(robot_game.contains("\r\n1,Team 1,120,180,,,\r\n"), "{robot_game}");
  let core_values = text(s.app.get(Some(&s.advisor), &path("core-values")).await).await;
  assert!(core_values.contains("\r\n1,Team 1,3,4,,,,,,TRUE\r\n"), "{core_values}");
  let ip = text(s.app.get(Some(&s.advisor), &path("innovation-project")).await).await;
  assert!(ip.contains("\r\n2,Team 2,2,2,2,2,2,2,2,2,2,2\r\n"), "{ip}");
  assert_eq!(
    s.app.get(Some(&s.advisor), &path("nope")).await.status(),
    StatusCode::NOT_FOUND
  );
}
