//! Printables: the data each template needs, rendered to PDF by `crate::print`.

use std::collections::HashMap;

use axum::extract::{Path, State};
use axum::http::header;
use axum::response::{IntoResponse, Response};
use chrono::{DateTime, Utc};
use chrono_tz::Tz;
use serde::Serialize;
use tms_core::model::{MatchState, Team};
use tms_seasons::FieldKind;
use uuid::Uuid;

use super::awards::load as load_deliberation;
use crate::AppState;
use crate::auth::Auth;
use crate::error::{ApiError, ApiResult};
use crate::print::{Printable, render};
use crate::repo::{blocks, events, schedule, teams, venue};

#[derive(Serialize)]
struct EventHead {
  name: String,
  code: String,
  dates: String,
}

#[derive(Serialize)]
struct Page<T: Serialize> {
  event: EventHead,
  printed: String,
  #[serde(flatten)]
  body: T,
}

#[derive(Serialize)]
struct TeamItem {
  kind: &'static str,
  what: String,
  place: String,
  start: String,
  end: String,
  #[serde(skip)]
  at: DateTime<Utc>,
}

#[derive(Serialize)]
struct TeamPage {
  number: String,
  name: String,
  affiliation: String,
  items: Vec<TeamItem>,
}

#[derive(Serialize)]
struct Row {
  label: String,
  start: String,
  end: String,
  teams: Vec<String>,
}

#[derive(Serialize)]
struct Sign {
  title: String,
  subtitle: String,
}

#[derive(Serialize)]
struct Sheet {
  team: String,
  team_name: String,
  #[serde(rename = "match")]
  game: String,
  table: String,
  time: String,
}

#[derive(Serialize)]
struct MissionPage {
  name: String,
  fields: Vec<FieldPage>,
}

#[derive(Serialize)]
struct FieldPage {
  label: String,
  options: Vec<String>,
}

#[derive(Serialize)]
struct RankRow {
  rank: String,
  number: String,
  name: String,
  scores: Vec<String>,
  best: String,
}

#[derive(Serialize)]
struct Certificate {
  award: String,
  place: String,
  team_number: String,
  team_name: String,
}

fn sorted(mut list: Vec<Team>) -> Vec<Team> {
  list.sort_by(|a, b| (a.number.len(), &a.number).cmp(&(b.number.len(), &b.number)));
  list
}

pub async fn print(
  State(state): State<AppState>,
  auth: Auth,
  Path((event_id, file)): Path<(Uuid, String)>,
) -> ApiResult<Response> {
  let printable = file
    .strip_suffix(".pdf")
    .and_then(Printable::from_name)
    .ok_or(ApiError::NotFound("printable"))?;
  auth.require(printable.role())?;
  let event = events::get(&state.pool, event_id)
    .await?
    .ok_or(ApiError::NotFound("event"))?;
  let tz: Tz = event
    .timezone
    .parse()
    .map_err(|_| ApiError::BadRequest("event.invalid_timezone", "the event's timezone is not valid".into()))?;
  let multi_day = event.ends_on > event.starts_on;
  let time = |at: DateTime<Utc>| {
    let local = at.with_timezone(&tz);
    if multi_day {
      local.format("%a %H:%M").to_string()
    } else {
      local.format("%H:%M").to_string()
    }
  };
  let head = EventHead {
    name: event.name.clone(),
    code: event.code.clone(),
    dates: if multi_day {
      format!(
        "{} – {}",
        event.starts_on.format("%-d %b"),
        event.ends_on.format("%-d %b %Y")
      )
    } else {
      event.starts_on.format("%-d %B %Y").to_string()
    },
  };
  let printed = Utc::now().with_timezone(&tz).format("%a %-d %b %Y, %H:%M").to_string();

  let mut conn = state.pool.acquire().await?;
  let team_list = sorted(teams::list(&mut *conn, event_id).await?);
  let by_id: HashMap<Uuid, &Team> = team_list.iter().map(|t| (t.id, t)).collect();
  let number = |id: Option<Uuid>| {
    id.and_then(|i| by_id.get(&i))
      .map(|t| t.number.clone())
      .unwrap_or_default()
  };
  let tables = venue::tables(&mut *conn, event_id).await?;
  let pods = venue::pods(&mut *conn, event_id).await?;
  let table_name: HashMap<Uuid, String> = tables.iter().map(|t| (t.id, t.name.clone())).collect();
  let matches: Vec<_> = schedule::matches(&mut conn, event_id)
    .await?
    .into_iter()
    .filter(|m| m.state != MatchState::Cancelled)
    .collect();
  let sessions = schedule::sessions(&mut conn, event_id).await?;

  let body = match printable {
    Printable::TeamSchedules => {
      let timetable = blocks::list(&mut *conn, event_id).await?;
      let pages: Vec<TeamPage> = team_list
        .iter()
        .map(|team| {
          let mut items: Vec<TeamItem> = Vec::new();
          for m in &matches {
            for slot in m.slots.iter().filter(|s| s.team_id == Some(team.id)) {
              items.push(TeamItem {
                kind: "match",
                what: m.label(),
                place: table_name.get(&slot.table_id).cloned().unwrap_or_default(),
                start: time(m.scheduled_start),
                end: time(m.scheduled_end),
                at: m.scheduled_start,
              });
            }
          }
          for s in &sessions {
            for slot in s.slots.iter().filter(|x| x.team_id == Some(team.id)) {
              let pod = pods.iter().find(|p| p.id == slot.pod_id);
              items.push(TeamItem {
                kind: "judging",
                what: "Judging session".into(),
                place: pod
                  .map(|p| {
                    p.room
                      .as_ref()
                      .map_or_else(|| p.name.clone(), |r| format!("{} ({r})", p.name))
                  })
                  .unwrap_or_default(),
                start: time(s.scheduled_start),
                end: time(s.scheduled_end),
                at: s.scheduled_start,
              });
            }
          }
          for b in &timetable {
            items.push(TeamItem {
              kind: "block",
              what: b.name.clone(),
              place: String::new(),
              start: time(b.starts_at),
              end: time(b.ends_at),
              at: b.starts_at,
            });
          }
          items.sort_by_key(|i| i.at);
          TeamPage {
            number: team.number.clone(),
            name: team.name.clone(),
            affiliation: team.affiliation.clone(),
            items,
          }
        })
        .collect();
      serde_json::json!({ "teams": pages })
    }
    Printable::MatchSchedule => {
      let rows: Vec<Row> = matches
        .iter()
        .map(|m| Row {
          label: m.label(),
          start: time(m.scheduled_start),
          end: time(m.scheduled_end),
          teams: tables
            .iter()
            .map(|t| number(m.slots.iter().find(|s| s.table_id == t.id).and_then(|s| s.team_id)))
            .collect(),
        })
        .collect();
      serde_json::json!({ "tables": tables.iter().map(|t| &t.name).collect::<Vec<_>>(), "matches": rows })
    }
    Printable::JudgingSchedule => {
      let rows: Vec<Row> = sessions
        .iter()
        .map(|s| Row {
          label: format!("Session {}", s.number),
          start: time(s.scheduled_start),
          end: time(s.scheduled_end),
          teams: pods
            .iter()
            .map(|p| number(s.slots.iter().find(|x| x.pod_id == p.id).and_then(|x| x.team_id)))
            .collect(),
        })
        .collect();
      serde_json::json!({ "pods": pods.iter().map(|p| &p.name).collect::<Vec<_>>(), "sessions": rows })
    }
    Printable::TableSigns => {
      let signs: Vec<Sign> = tables
        .iter()
        .map(|t| Sign {
          title: t.name.clone(),
          subtitle: "Robot game table".into(),
        })
        .collect();
      serde_json::json!({ "title": "Table signs", "signs": signs })
    }
    Printable::PodSigns => {
      let signs: Vec<Sign> = pods
        .iter()
        .map(|p| Sign {
          title: p.name.clone(),
          subtitle: p.room.clone().unwrap_or_else(|| "Judging".into()),
        })
        .collect();
      serde_json::json!({ "title": "Pod signs", "signs": signs })
    }
    Printable::Scoresheets => {
      let season = tms_seasons::by_id(&event.season_id).ok_or(ApiError::NotFound("season"))?;
      let sheets: Vec<Sheet> = matches
        .iter()
        .flat_map(|m| {
          m.slots.iter().filter(|s| s.team_id.is_some()).map(|s| Sheet {
            team: number(s.team_id),
            team_name: s
              .team_id
              .and_then(|id| by_id.get(&id))
              .map(|t| t.name.clone())
              .unwrap_or_default(),
            game: m.label(),
            table: table_name.get(&s.table_id).cloned().unwrap_or_default(),
            time: time(m.scheduled_start),
          })
        })
        .collect();
      let missions: Vec<MissionPage> = season
        .missions
        .iter()
        .map(|m| MissionPage {
          name: m.name.into(),
          fields: m
            .fields
            .iter()
            .map(|f| FieldPage {
              label: f.label.into(),
              options: match &f.kind {
                FieldKind::Bool => vec!["No".into(), "Yes".into()],
                FieldKind::Count { max } => (0..=*max).map(|n| n.to_string()).collect(),
                FieldKind::Choice { options } => options.iter().map(|o| o.label.to_owned()).collect(),
              },
            })
            .collect(),
        })
        .collect();
      serde_json::json!({ "sheets": sheets, "missions": missions })
    }
    Printable::Rankings => {
      let rows = super::game::rankings(&state.pool, event_id).await?;
      let rounds = rows.first().map_or(0, |r| r.scores.len());
      let opt = |v: Option<u16>| v.map_or_else(|| "–".into(), |s| s.to_string());
      let rows: Vec<RankRow> = rows
        .into_iter()
        .map(|r| RankRow {
          rank: r.rank.to_string(),
          number: number(Some(r.team_id)),
          name: by_id.get(&r.team_id).map(|t| t.name.clone()).unwrap_or_default(),
          scores: r.scores.iter().map(|s| opt(*s)).collect(),
          best: opt(r.best),
        })
        .collect();
      serde_json::json!({ "rounds": (1..=rounds).map(|r| format!("Round {r}")).collect::<Vec<_>>(), "rows": rows })
    }
    Printable::Certificates => {
      let d = load_deliberation(&mut conn, event_id).await?;
      let mut awards = d.awards.clone();
      awards.sort_by_key(|a| a.sort_order);
      let team = |id: Uuid| {
        by_id
          .get(&id)
          .map(|t| (t.number.clone(), t.name.clone()))
          .unwrap_or_default()
      };
      let mut certificates = Vec::new();
      for award in &awards {
        let mut winners: Vec<_> = d.winners.iter().filter(|w| w.award_id == award.id).collect();
        winners.sort_by_key(|w| w.place);
        for w in winners {
          let (team_number, team_name) = team(w.team_id);
          certificates.push(Certificate {
            award: format!("{} Award", award.name),
            place: if award.places > 1 {
              tms_core::deliberation::place_label(w.place).to_owned()
            } else {
              String::new()
            },
            team_number,
            team_name,
          });
        }
      }
      for id in &d.advancing {
        let (team_number, team_name) = team(*id);
        certificates.push(Certificate {
          award: "Advancing to the next level".into(),
          place: String::new(),
          team_number,
          team_name,
        });
      }
      serde_json::json!({ "program": "FIRST LEGO League Challenge", "certificates": certificates })
    }
  };
  let page = Page {
    event: head,
    printed,
    body,
  };
  let pdf = tokio::task::spawn_blocking(move || render(printable, &page))
    .await
    .map_err(|e| ApiError::Internal(e.into()))??;
  let disposition = format!("inline; filename=\"{}-{}.pdf\"", event.code, printable.name());
  Ok(
    (
      [
        (header::CONTENT_TYPE, "application/pdf".to_owned()),
        (header::CONTENT_DISPOSITION, disposition),
      ],
      pdf,
    )
      .into_response(),
  )
}
