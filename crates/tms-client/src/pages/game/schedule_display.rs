//! The schedule screen: the next matches and the next judging sessions, side by side.

use chrono::TimeDelta;
use dioxus::prelude::*;
use tms_core::Topic;
use tms_core::model::MatchState;

use super::displays::DisplayFrame;
use super::shared::{sorted_matches, table_name, team_label, use_server_now};
use crate::net::realtime::{Realtime, use_subscription};
use crate::pages::judging::shared::sorted_sessions;
use crate::time::format_time;

const MATCH_MINUTES: i64 = 60;
const JUDGING_MINUTES: i64 = 120;

#[component]
pub fn ScheduleDisplay() -> Element {
  use_subscription(Topic::Matches);
  use_subscription(Topic::JudgingSessions);
  use_subscription(Topic::Teams);
  use_subscription(Topic::Tables);
  use_subscription(Topic::Pods);
  let realtime = use_context::<Realtime>();
  let now = use_server_now();
  let timezone = realtime
    .stores
    .event
    .read()
    .as_ref()
    .map_or_else(|| "UTC".to_owned(), |e| e.timezone.clone());
  let teams = realtime.stores.teams.read().clone();
  let tables = realtime.stores.tables.read().clone();
  let pods = realtime.stores.pods.read().clone();
  let matches: Vec<_> = sorted_matches(&realtime.stores.matches.read())
    .into_iter()
    .filter(|m| {
      matches!(
        m.state,
        MatchState::Scheduled | MatchState::Staged | MatchState::Running
      ) && m.scheduled_start <= now() + TimeDelta::minutes(MATCH_MINUTES)
    })
    .take(12)
    .collect();
  let sessions: Vec<_> = sorted_sessions(&realtime.stores.sessions.read())
    .into_iter()
    .filter(|s| s.scheduled_end >= now() && s.scheduled_start <= now() + TimeDelta::minutes(JUDGING_MINUTES))
    .take(6)
    .collect();

  rsx! {
    DisplayFrame { title: "Schedule",
      div { class: "grid flex-1 gap-8 lg:grid-cols-2",
        section {
          h2 { class: "mb-3 text-3xl font-bold", "Robot game" }
          if matches.is_empty() {
            p { class: "text-xl text-muted", "No matches in the next hour." }
          }
          table { class: "w-full text-xl",
            tbody {
              for m in matches {
                tr { class: "border-b border-line align-top",
                  td { class: "py-2 pr-4 font-mono", "{format_time(m.scheduled_start, &timezone)}" }
                  td { class: "py-2 pr-4 font-semibold", "{m.label()}" }
                  td { class: "py-2",
                    for slot in m.slots.iter().filter(|s| s.team_id.is_some()) {
                      div {
                        span { class: "text-muted", "{table_name(&tables, slot.table_id)} " }
                        "{team_label(&teams, slot.team_id)}"
                      }
                    }
                  }
                }
              }
            }
          }
        }
        section {
          h2 { class: "mb-3 text-3xl font-bold", "Judging" }
          if sessions.is_empty() {
            p { class: "text-xl text-muted", "No judging sessions in the next two hours." }
          }
          table { class: "w-full text-xl",
            tbody {
              for s in sessions {
                tr { class: "border-b border-line align-top",
                  td { class: "py-2 pr-4 font-mono", "{format_time(s.scheduled_start, &timezone)}" }
                  td { class: "py-2 pr-4 font-semibold", "Session {s.number}" }
                  td { class: "py-2",
                    for slot in s.slots.iter().filter(|s| s.team_id.is_some()) {
                      div {
                        span { class: "text-muted", {pods.iter().find(|p| p.id == slot.pod_id).map_or_else(|| "Pod".to_owned(), |p| p.name.clone())} " " }
                        "{team_label(&teams, slot.team_id)}"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
