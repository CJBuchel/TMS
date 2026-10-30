//! CSV exports for the judge advisor. The judging ones follow the Official Judging Spreadsheet's input pages, so
//! their columns can be pasted straight into it.

use std::collections::HashMap;
use std::fmt::Write;

use axum::extract::{Path, State};
use axum::http::header;
use axum::response::{IntoResponse, Response};
use tms_core::Role;
use tms_core::deliberation::{AwardKind, Deliberation, TeamScores, place_label};
use tms_core::judging::{Nomination, RubricStatus};
use tms_core::model::Team;
use uuid::Uuid;

use super::awards::load;
use crate::AppState;
use crate::auth::Auth;
use crate::error::{ApiError, ApiResult};
use crate::repo::{events, judging, teams};

/// The exports, by file name without `.csv`.
pub const EXPORTS: [&str; 8] = [
  "results",
  "rankings",
  "innovation-project",
  "robot-design",
  "core-values",
  "robot-game",
  "rubrics",
  "awards",
];

#[derive(Default)]
struct Csv(String);

impl Csv {
  fn row<S: AsRef<str>>(&mut self, cells: impl IntoIterator<Item = S>) {
    let mut first = true;
    for cell in cells {
      if !first {
        self.0.push(',');
      }
      first = false;
      let cell = cell.as_ref();
      if cell.contains([',', '"', '\n', '\r']) {
        let _ = write!(self.0, "\"{}\"", cell.replace('"', "\"\""));
      } else {
        self.0.push_str(cell);
      }
    }
    self.0.push_str("\r\n");
  }
}

fn opt<T: ToString>(v: Option<T>) -> String {
  v.map(|v| v.to_string()).unwrap_or_default()
}

/// Five cells, as the spreadsheet holds five robot game and Gracious Professionalism scores.
fn five<T: ToString>(values: &[T]) -> Vec<String> {
  (0..5)
    .map(|i| values.get(i).map(ToString::to_string).unwrap_or_default())
    .collect()
}

pub async fn export(
  State(state): State<AppState>,
  auth: Auth,
  Path((event_id, file)): Path<(Uuid, String)>,
) -> ApiResult<Response> {
  auth.require(Role::JudgeAdvisor)?;
  let name = file.strip_suffix(".csv").unwrap_or(&file);
  if !EXPORTS.contains(&name) {
    return Err(ApiError::NotFound("export"));
  }
  let event = events::get(&state.pool, event_id)
    .await?
    .ok_or(ApiError::NotFound("event"))?;
  let mut conn = state.pool.acquire().await?;
  let d = load(&mut conn, event_id).await?;
  let team_list = teams::list(&mut *conn, event_id).await?;
  let by_id: HashMap<Uuid, &Team> = team_list.iter().map(|t| (t.id, t)).collect();
  let team = |id: Uuid| -> (String, String) {
    by_id
      .get(&id)
      .map(|t| (t.number.clone(), t.name.clone()))
      .unwrap_or_default()
  };
  let mut csv = Csv::default();
  match name {
    "results" => results(&mut csv, &d, &team),
    "rankings" => {
      let rows = super::game::rankings(&state.pool, event_id).await?;
      let rounds = rows.first().map_or(0, |r| r.scores.len());
      let mut header = vec![
        "Rank".to_owned(),
        "Team Number".into(),
        "Team Name".into(),
        "Best".into(),
      ];
      header.extend((1..=rounds).map(|r| format!("Round {r}")));
      csv.row(header);
      for r in rows {
        let (number, team_name) = team(r.team_id);
        let mut cells = vec![r.rank.to_string(), number, team_name, opt(r.best)];
        cells.extend(r.scores.iter().map(|s| opt(*s)));
        csv.row(cells);
      }
    }
    "innovation-project" | "robot-design" => {
      let season = tms_seasons::by_id(&event.season_id).ok_or(ApiError::NotFound("season"))?;
      let rubric = season
        .rubrics
        .iter()
        .find(|r| r.id == if name == "innovation-project" { "ip" } else { "rd" })
        .ok_or(ApiError::NotFound("rubric"))?;
      let mut header = vec!["Team Number".to_owned(), "Team Name".into()];
      for section in rubric.sections {
        for row in section.rows {
          header.push(format!(
            "{} - {}{}",
            section.name,
            row.label,
            if row.core_values { " (CV)" } else { "" }
          ));
        }
      }
      csv.row(header);
      for r in accepted(&state, event_id).await? {
        let (number, team_name) = team(r.team_id);
        let mut cells = vec![number, team_name];
        cells.extend(rubric.rows().map(|row| opt(r.scores.get(row.id))));
        csv.row(cells);
      }
    }
    "core-values" => {
      csv.row([
        "Team Number",
        "Team Name",
        "Gracious Professionalism 1",
        "Gracious Professionalism 2",
        "Gracious Professionalism 3",
        "Gracious Professionalism 4",
        "Gracious Professionalism 5",
        "Breakthrough Selection",
        "Rising All-Star Selection",
        "Motivate Selection",
      ]);
      let inputs = judging::team_inputs(&mut conn, event_id).await?;
      for input in inputs {
        let (number, team_name) = team(input.team_id);
        let mut cells = vec![number, team_name];
        cells.extend(five(&input.gp));
        let selected = d.nominations.get(&input.team_id);
        for n in Nomination::ALL {
          cells.push(if selected.is_some_and(|s| s.contains(&n)) {
            "TRUE".into()
          } else {
            String::new()
          });
        }
        csv.row(cells);
      }
    }
    "robot-game" => {
      csv.row([
        "Team Number",
        "Team Name",
        "Robot Game 1 Score",
        "Robot Game 2 Score",
        "Robot Game 3 Score",
        "Robot Game 4 Score",
        "Robot Game 5 Score",
      ]);
      for t in &d.teams {
        let (number, team_name) = team(t.team_id);
        let mut cells = vec![number, team_name];
        cells.extend(five(&t.robot_game_scores));
        csv.row(cells);
      }
    }
    "rubrics" => {
      csv.row([
        "Team Number",
        "Team Name",
        "Judges",
        "Innovation Project",
        "Robot Design",
        "Core Values rows",
        "Exceeds comments",
        "Core Values: great job",
        "Core Values: think about",
        "Innovation Project: great job",
        "Innovation Project: think about",
        "Robot Design: great job",
        "Robot Design: think about",
      ]);
      for r in accepted(&state, event_id).await? {
        let (number, team_name) = team(r.team_id);
        let comments: Vec<String> = r
          .exceeds_comments
          .iter()
          .map(|(row, c)| format!("{row}: {c}"))
          .collect();
        let f = &r.feedback;
        csv.row([
          number,
          team_name,
          r.judge_names.clone(),
          r.innovation_project.to_string(),
          r.robot_design.to_string(),
          r.core_values_rows.to_string(),
          comments.join("\n"),
          f.core_values_great.clone(),
          f.core_values_think.clone(),
          f.innovation_project_great.clone(),
          f.innovation_project_think.clone(),
          f.robot_design_great.clone(),
          f.robot_design_think.clone(),
        ]);
      }
    }
    _ => {
      csv.row(["Award", "Place", "Team Number", "Team Name", "Note"]);
      let mut awards = d.awards.clone();
      awards.sort_by_key(|a| a.sort_order);
      for award in &awards {
        for w in d.winners.iter().filter(|w| w.award_id == award.id) {
          let (number, team_name) = team(w.team_id);
          csv.row([
            award.name.clone(),
            place_label(w.place).to_owned(),
            number,
            team_name,
            w.note.clone(),
          ]);
        }
      }
      for (i, id) in d.advancing.iter().enumerate() {
        let (number, team_name) = team(*id);
        csv.row([
          "Advancing".to_owned(),
          (i + 1).to_string(),
          number,
          team_name,
          String::new(),
        ]);
      }
    }
  }
  let disposition = format!("attachment; filename=\"{}-{name}.csv\"", event.code);
  Ok(
    (
      [
        (header::CONTENT_TYPE, "text/csv; charset=utf-8".to_owned()),
        (header::CONTENT_DISPOSITION, disposition),
      ],
      // A byte order mark so Excel reads the file as UTF-8.
      format!("\u{feff}{}", csv.0),
    )
      .into_response(),
  )
}

async fn accepted(state: &AppState, event_id: Uuid) -> ApiResult<Vec<tms_core::judging::Rubric>> {
  let mut all = judging::list(&state.pool, event_id).await?;
  all.retain(|r| r.status == RubricStatus::Accepted);
  all.sort_by_key(|r| (r.team_number.len(), r.team_number.clone()));
  Ok(all)
}

/// The spreadsheet's Results and Rankings page.
fn results(csv: &mut Csv, d: &Deliberation, team: &dyn Fn(Uuid) -> (String, String)) {
  csv.row([
    "Team Number",
    "Team Name",
    "Robot Game Score 1",
    "Robot Game Score 2",
    "Robot Game Score 3",
    "Robot Game Score 4",
    "Robot Game Score 5",
    "Max Robot Game Score",
    "Robot Game Rank",
    "Core Values Rank",
    "Innovation Project Rank",
    "Robot Design Rank",
    "Champion's Score",
    "Champion's Rank",
    "Breakthrough",
    "Rising All-Star",
    "Motivate",
    "Award",
    "Award Place",
    "Advance?",
    "Core Values Score",
    "Innovation Project Score",
    "Robot Design Score",
  ]);
  let mut teams: Vec<&TeamScores> = d.teams.iter().collect();
  teams.sort_by_key(|t| t.champions_rank);
  for t in teams {
    let (number, team_name) = team(t.team_id);
    let selected = d.nominations.get(&t.team_id);
    let judged = d.winners.iter().find(|w| {
      w.team_id == t.team_id
        && d
          .award(w.award_id)
          .is_some_and(|a| a.kind.judged() && a.kind != AwardKind::Local)
    });
    let mut cells = vec![number, team_name];
    cells.extend(five(&t.robot_game_scores));
    cells.extend([
      opt(t.robot_game),
      t.robot_game_rank.to_string(),
      t.core_values_rank.to_string(),
      t.innovation_project_rank.to_string(),
      t.robot_design_rank.to_string(),
      t.champions_score.to_string(),
      t.champions_rank.to_string(),
    ]);
    for n in Nomination::ALL {
      cells.push(if selected.is_some_and(|s| s.contains(&n)) {
        "TRUE".into()
      } else {
        String::new()
      });
    }
    cells.extend([
      judged
        .and_then(|w| d.award(w.award_id))
        .map(|a| a.name.clone())
        .unwrap_or_default(),
      judged.map(|w| place_label(w.place).to_owned()).unwrap_or_default(),
      if d.advancing.contains(&t.team_id) {
        "Yes".into()
      } else {
        String::new()
      },
      opt(t.core_values),
      opt(t.innovation_project),
      opt(t.robot_design),
    ]);
    csv.row(cells);
  }
}
