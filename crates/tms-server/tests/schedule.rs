//! Generating a schedule, editing it by hand, and the live list of schedule issues.

mod common;

use common::{TestApp, error_code, ok_json, twelve_team_schedule};
use reqwest::StatusCode;
use tms_core::dto::{
  EventSummary, GeneratePreview, GenerateRequest, ImportPreview, MoveRequest, SlotAssignRequest, SwapOption,
};
use tms_core::model::{GameMatch, JudgingSession, MatchKind};
use tms_core::validation::{IssueCode, IssueSeverity, ScheduleIssue};
use tms_core::ws::{ClientMessage, ServerMessage, TopicItem};
use tms_core::{Role, Topic};

async fn imported(code: &str) -> (TestApp, String, EventSummary) {
  let app = TestApp::spawn().await;
  let admin = app.admin_token().await;
  let event = app.active_event(&admin, code).await;
  let preview: ImportPreview = ok_json(
    app
      .post_text(
        &admin,
        &format!("/events/{}/import/tiab?commit=true", event.id),
        &twelve_team_schedule(),
      )
      .await,
  )
  .await;
  assert!(
    preview.issues.iter().all(|i| i.severity == IssueSeverity::Warning),
    "{:?}",
    preview.issues
  );
  (app, admin, event)
}

fn errors(issues: &[ScheduleIssue]) -> Vec<&ScheduleIssue> {
  issues.iter().filter(|i| i.severity == IssueSeverity::Error).collect()
}

#[tokio::test]
async fn a_generated_schedule_previews_then_commits_without_errors() {
  let (app, admin, event) = imported("SCH-01").await;
  let request = GenerateRequest {
    match_start_local: "2026-11-14T09:00:00".parse().unwrap(),
    judging_start_local: "2026-11-14T09:00:00".parse().unwrap(),
    match_cycle_minutes: 8,
    seed: 4,
  };
  let path = format!("/events/{}/schedule/generate", event.id);
  let preview: GeneratePreview = ok_json(app.post(Some(&admin), &path, &request).await).await;
  assert_eq!(errors(&preview.preview.issues), Vec::<&ScheduleIssue>::new());
  assert_eq!(preview.preview.replaces_matches, 18, "the imported schedule would go");
  assert_eq!(preview.sessions.len(), 12, "one pod, twelve sessions");
  let ranking_slots: usize = preview
    .matches
    .iter()
    .filter(|m| m.kind == Some(MatchKind::Ranking))
    .map(|m| m.teams.len())
    .sum();
  assert_eq!(ranking_slots, 36, "three ranking matches for each of twelve teams");
  let again: GeneratePreview = ok_json(app.post(Some(&admin), &path, &request).await).await;
  assert_eq!(again, preview, "the same request gives the same schedule");

  ok_json::<GeneratePreview>(app.post(Some(&admin), &format!("{path}?commit=true"), &request).await).await;
  let matches: Vec<GameMatch> = ok_json(app.get(Some(&admin), &format!("/events/{}/matches", event.id)).await).await;
  assert_eq!(matches.len(), preview.matches.len());
  let mut rounds: Vec<i32> = matches
    .iter()
    .filter(|m| m.kind == MatchKind::Ranking)
    .flat_map(|m| m.slots.iter().filter_map(|s| s.round))
    .collect();
  rounds.sort_unstable();
  rounds.dedup();
  assert_eq!(rounds, [1, 2, 3]);
  let issues: Vec<ScheduleIssue> = ok_json(
    app
      .get(Some(&admin), &format!("/events/{}/schedule/issues", event.id))
      .await,
  )
  .await;
  assert_eq!(errors(&issues), Vec::<&ScheduleIssue>::new());
}

#[tokio::test]
async fn an_edit_into_a_conflict_is_refused_unless_forced() {
  let (app, admin, event) = imported("SCH-02").await;
  app
    .create_user("hr", "head-ref-password-1", &[Role::HeadReferee], false)
    .await;
  let hr = ok_json::<tms_core::dto::AuthResponse>(app.login("hr", "head-ref-password-1").await)
    .await
    .token;
  let issues_path = format!("/events/{}/schedule/issues", event.id);
  let before: Vec<ScheduleIssue> = ok_json(app.get(Some(&hr), &issues_path).await).await;
  assert_eq!(errors(&before), Vec::<&ScheduleIssue>::new());

  let mut ws = app.ws_ready(Some(&admin)).await;
  ws.send(&ClientMessage::SetSubscriptions {
    topics: vec![Topic::Issues],
  })
  .await;
  assert!(matches!(
    ws.recv().await,
    ServerMessage::Snapshot {
      topic: Topic::Issues,
      ..
    }
  ));

  // Ranking 1 (teams 1 and 2) moved onto team 1's judging session at 11:00.
  let matches: Vec<GameMatch> = ok_json(app.get(Some(&admin), &format!("/events/{}/matches", event.id)).await).await;
  let first = matches.iter().find(|m| m.number == 1).unwrap();
  let move_path = format!("/matches/{}/move", first.id);
  let mut body = MoveRequest {
    start_local: "2026-11-14T11:05:00".parse().unwrap(),
    force: false,
  };
  let refused = app.post(Some(&admin), &move_path, &body).await;
  assert_eq!(refused.status(), StatusCode::UNPROCESSABLE_ENTITY);
  let detail: serde_json::Value = refused.json().await.unwrap();
  assert_eq!(detail["code"], "schedule.conflict");
  assert!(
    detail["details"]
      .as_array()
      .unwrap()
      .iter()
      .any(|d| d == "Team 1 is in Judging 1 and Ranking 1 at the same time."),
    "{detail}"
  );
  let unchanged: Vec<ScheduleIssue> = ok_json(app.get(Some(&admin), &issues_path).await).await;
  assert_eq!(unchanged, before, "nothing changed");

  body.force = true;
  let after: Vec<ScheduleIssue> = ok_json(app.post(Some(&admin), &move_path, &body).await).await;
  assert!(after.iter().any(|i| i.code == IssueCode::Overlap));
  // Only the issues that changed are pushed, not the whole list again.
  let mut pushed = Vec::new();
  for m in ws.drain().await {
    match m {
      ServerMessage::Upsert {
        item: TopicItem::Issue(i),
        ..
      } => pushed.push(i),
      ServerMessage::Snapshot {
        topic: Topic::Issues, ..
      } => panic!("the issue list was sent whole"),
      _ => {}
    }
  }
  assert!(pushed.iter().any(|i| i.code == IssueCode::Overlap), "{pushed:?}");
  let listed: Vec<ScheduleIssue> = ok_json(app.get(Some(&admin), &issues_path).await).await;
  assert_eq!(errors(&listed).len(), errors(&after).len());

  // The best swap for team 1's slot in Ranking 1 adds no errors.
  let slot = first.slots.iter().find(|s| s.round == Some(1)).unwrap();
  let options: Vec<SwapOption> = ok_json(app.get(Some(&admin), &format!("/match-slots/{}/swaps", slot.id)).await).await;
  assert_ne!(options.len(), 0);
  assert!(options[0].new_errors.is_empty(), "{:?}", options[0]);

  // Emptying the slot leaves team 1 one ranking match short.
  let emptied = app
    .post(
      Some(&admin),
      &format!("/match-slots/{}/assign", slot.id),
      &SlotAssignRequest {
        team_id: None,
        force: false,
      },
    )
    .await;
  assert_eq!(
    error_code(emptied).await,
    (StatusCode::UNPROCESSABLE_ENTITY, "schedule.conflict".into())
  );
}

#[tokio::test]
async fn started_matches_and_sessions_stay_put() {
  let (app, admin, event) = imported("SCH-03").await;
  let matches: Vec<GameMatch> = ok_json(app.get(Some(&admin), &format!("/events/{}/matches", event.id)).await).await;
  let first = matches.iter().find(|m| m.number == 1).unwrap();
  ok_json::<GameMatch>(
    app
      .post(Some(&admin), &format!("/matches/{}/stage", first.id), &())
      .await,
  )
  .await;
  let moved = app
    .post(
      Some(&admin),
      &format!("/matches/{}/move", first.id),
      &MoveRequest {
        start_local: "2026-11-14T09:01:00".parse().unwrap(),
        force: true,
      },
    )
    .await;
  assert_eq!(
    error_code(moved).await,
    (StatusCode::CONFLICT, "match.invalid_state".into())
  );
  let sessions: Vec<JudgingSession> = ok_json(
    app
      .get(Some(&admin), &format!("/events/{}/judging-sessions", event.id))
      .await,
  )
  .await;
  let later = &sessions[11];
  let moved: Vec<ScheduleIssue> = ok_json(
    app
      .post(
        Some(&admin),
        &format!("/judging-sessions/{}/move", later.id),
        &MoveRequest {
          start_local: "2026-11-14T17:00:00".parse().unwrap(),
          force: false,
        },
      )
      .await,
  )
  .await;
  assert_eq!(
    errors(&moved),
    Vec::<&ScheduleIssue>::new(),
    "a session moved to a free time"
  );
  app
    .create_user("judge", "judge-password-1", &[Role::Judge], false)
    .await;
  let judge = ok_json::<tms_core::dto::AuthResponse>(app.login("judge", "judge-password-1").await)
    .await
    .token;
  assert_eq!(
    app
      .get(Some(&judge), &format!("/events/{}/schedule/issues", event.id))
      .await
      .status(),
    StatusCode::FORBIDDEN
  );
}

#[tokio::test]
async fn two_slots_of_one_match_swap_sides() {
  let (app, admin, event) = imported("SCH-04").await;
  let matches: Vec<GameMatch> = ok_json(app.get(Some(&admin), &format!("/events/{}/matches", event.id)).await).await;
  let first = matches.iter().find(|m| m.number == 1).unwrap();
  let (a, b) = (&first.slots[0], &first.slots[1]);
  ok_json::<Vec<ScheduleIssue>>(
    app
      .post(
        Some(&admin),
        "/match-slots/swap",
        &tms_core::dto::SlotSwapRequest {
          a: a.id,
          b: b.id,
          force: false,
        },
      )
      .await,
  )
  .await;
  let after: Vec<GameMatch> = ok_json(app.get(Some(&admin), &format!("/events/{}/matches", event.id)).await).await;
  let swapped = after.iter().find(|m| m.id == first.id).unwrap();
  assert_eq!(
    (swapped.slots[0].team_id, swapped.slots[1].team_id),
    (b.team_id, a.team_id)
  );
}

#[tokio::test]
async fn the_schedule_exports_as_a_file_that_imports_again() {
  let (app, admin, event) = imported("SCH-05").await;
  let res = app
    .get(Some(&admin), &format!("/events/{}/schedule/export.csv", event.id))
    .await;
  assert_eq!(res.status(), StatusCode::OK);
  let csv = res.text().await.unwrap();
  assert!(csv.starts_with("Version Number,1\n"), "{csv}");
  let preview: ImportPreview = ok_json(
    app
      .post_text(&admin, &format!("/events/{}/import/tiab", event.id), &csv)
      .await,
  )
  .await;
  assert_eq!(
    (
      preview.teams_added.len(),
      preview.teams_updated.len(),
      preview.ranking_matches,
      preview.judging_sessions
    ),
    (0, 0, 18, 12)
  );
}
