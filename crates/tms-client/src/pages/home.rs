use dioxus::prelude::*;
use tms_core::dto::{Banner, BannerSeverity, CreateBannerRequest};
use tms_core::judging::RubricStatus;
use tms_core::model::{GameMatch, MatchKind, MatchState, QueueState, ScoresheetStatus};
use tms_core::queue::Presence;
use tms_core::role::has_role;
use tms_core::validation::IssueSeverity;
use tms_core::{Role, Topic};
use tms_ui::{Badge, Button, ButtonSize, ButtonVariant, Card, Checkbox, KeyValue, TextField, Tone};
use uuid::Uuid;

use crate::components::{ErrorBox, token};
use crate::net::api::{self, ApiFailure};
use crate::net::realtime::{Realtime, use_subscription};
use crate::pages::game::shared::{TimerClock, sorted_matches, use_server_now};
use crate::pages::game::{FieldPanel, MissingSheets};
use crate::routes::Route;
use crate::store::session::Session;
use crate::time::format_time;

/// The screens each role gets, so whoever is logged in can see what this device is for. Screens that exist link
/// to their page; the rest are marked planned until their phase lands.
fn screens() -> [(Role, &'static str, &'static str, Option<Route>); 14] {
  [
    (
      Role::Admin,
      "Event setup",
      "Teams, tables and pods; generate or import the schedule; awards, users and access keys",
      Some(Route::SetupEvent {}),
    ),
    (
      Role::HeadReferee,
      "Match control",
      "Stage matches, run the timer, review scoresheets",
      Some(Route::MatchControl {}),
    ),
    (
      Role::Referee,
      "Referee station",
      "This table's matches and scoresheets",
      Some(Route::RefereeStation {}),
    ),
    (
      Role::Queuer,
      "Queue board",
      "Call teams and track them to the tables",
      Some(Route::QueueBoard {}),
    ),
    (
      Role::Emcee,
      "Emcee",
      "Staged match, team line-up, start button, top ten",
      Some(Route::Emcee {}),
    ),
    (
      Role::JudgeAdvisor,
      "Judging",
      "Every pod at a glance, rubric review, scores and ranks",
      Some(Route::JudgingDashboard {}),
    ),
    (
      Role::JudgeAdvisor,
      "Deliberation",
      "Awards in the official order, advancement, finalizing, exports",
      Some(Route::JudgingDeliberation {}),
    ),
    (
      Role::HeadReferee,
      "Print",
      "Schedules, signs, paper scoresheets, ranking and certificates as PDFs",
      Some(Route::Print {}),
    ),
    (
      Role::Judge,
      "Judge station",
      "This pod's session timer, teams and rubrics; rubrics work offline",
      Some(Route::JudgeStation {}),
    ),
    (
      Role::Display,
      "Scoreboard display",
      "Full-screen robot game ranking for the venue; no login needed",
      Some(Route::ScoreboardDisplay {}),
    ),
    (
      Role::Display,
      "Timer display",
      "Full-screen match clock and line-up, with sounds; no login needed",
      Some(Route::TimerDisplay { tables: String::new() }),
    ),
    (
      Role::Display,
      "Queue display",
      "Full-screen list of teams to come to the queue, for the pits; no login needed",
      Some(Route::QueueDisplay { tables: String::new() }),
    ),
    (
      Role::Display,
      "Schedule display",
      "Full-screen list of the next matches and judging sessions; no login needed",
      Some(Route::ScheduleDisplay {}),
    ),
    (
      Role::Display,
      "Awards display",
      "The awards ceremony, one award at a time; no login needed",
      Some(Route::AwardsDisplay {}),
    ),
  ]
}

#[component]
pub fn Home() -> Element {
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let state = session.read();
  let roles = state.roles();
  let event = realtime.stores.event.read().clone();
  let primary = Route::primary(&roles);
  let elsewhere = primary != Route::Home {};
  use_effect(move || {
    if elsewhere {
      navigator().replace(primary.clone());
    }
  });
  if elsewhere {
    return rsx! {};
  }
  // An admin knows every screen; the overview above is their page, so the list stays short.
  let admin = has_role(&roles, Role::Admin);

  rsx! {
    if let Some(e) = event.clone().filter(|_| has_role(&roles, Role::Admin)) {
      div { class: "mb-4", EventHealth {} }
      div { class: "mb-4 grid items-start gap-4 xl:grid-cols-[minmax(0,3fr)_minmax(0,2fr)]", "data-testid": "admin-overview",
        div { class: "flex flex-col gap-4",
          RightNow {}
          MissingSheets {}
          FieldPanel { timezone: e.timezone.clone() }
        }
        div { class: "flex flex-col gap-4",
          Announcements { event_id: e.id }
          Stations {}
        }
      }
    }
    div { class: "grid items-start gap-4 lg:grid-cols-[minmax(0,2fr)_minmax(0,1fr)]",
      Card { title: "Your screens",
        ul { class: if admin { "grid gap-2 sm:grid-cols-2 xl:grid-cols-3" } else { "grid gap-3 sm:grid-cols-2" },
          for (role , name , description , route) in screens().into_iter().filter(|(r, _, _, _)| has_role(&roles, *r)) {
            li { class: if admin { "group relative flex flex-col gap-1 rounded-control border border-line px-3 py-2 transition hover:border-primary hover:shadow-panel" } else { "group relative flex flex-col gap-2 rounded-control border border-line p-4 transition hover:border-primary hover:shadow-panel" },
              div { class: "flex items-start justify-between gap-2",
                match route.clone() {
                  Some(to) => rsx! { Link { to, class: "font-semibold group-hover:text-primary after:absolute after:inset-0", "{name}" } },
                  None => rsx! { p { class: "font-semibold", "{name}" } },
                }
                Badge { "{role.label()}" }
              }
              if !admin {
                p { class: "text-sm text-muted", "{description}" }
              }
              if route.is_none() {
                Badge { tone: Tone::Neutral, "Planned" }
              }
            }
          }
        }
      }
      Card { title: "Event",
        match event {
          Some(e) => rsx! {
            dl {
              KeyValue { label: "Name", "{e.name}" }
              KeyValue { label: "Code", span { class: "font-mono", "{e.code}" } }
              KeyValue { label: "Season", "{e.season_id}" }
              KeyValue { label: "Dates", "{e.starts_on} to {e.ends_on}" }
              KeyValue { label: "Timezone", "{e.timezone}" }
            }
          },
          None => rsx! { p { class: "text-sm text-muted", "No event is active. An admin activates one from event setup." } },
        }
      }
    }
  }
}

/// One number with what it means; `tone` colours the number when something needs attention.
#[component]
fn Kpi(
  label: String,
  value: String,
  detail: String,
  #[props(default)] tone: Tone,
  #[props(default)] progress: Option<u32>,
) -> Element {
  let colour = match tone {
    Tone::Danger => "text-danger",
    Tone::Warning => "text-warning-strong",
    Tone::Success => "text-success-strong",
    _ => "text-fg",
  };
  rsx! {
    div { class: "rounded-control flex flex-col gap-1 border border-line bg-surface p-4",
      span { class: "text-sm font-medium text-muted", "{label}" }
      span { class: "text-3xl font-extrabold tabular-nums {colour}", "{value}" }
      if let Some(p) = progress {
        div { class: "h-1.5 w-full overflow-hidden rounded-full bg-surface-2",
          div { class: "h-1.5 rounded-full bg-primary", style: "width: {p}%" }
        }
      }
      span { class: "text-sm text-muted", "{detail}" }
    }
  }
}

/// The admin's view of the whole event: how far along it is and what needs someone's attention.
#[component]
fn EventHealth() -> Element {
  for topic in [
    Topic::Matches,
    Topic::JudgingSessions,
    Topic::Scoresheets,
    Topic::Rubrics,
    Topic::Presence,
    Topic::Issues,
    Topic::Tables,
    Topic::Pods,
  ] {
    use_subscription(topic);
  }
  let realtime = use_context::<Realtime>();
  let now = use_server_now();
  let s = realtime.stores;
  let matches = s.matches.read().clone();
  let ranking: Vec<_> = matches.iter().filter(|m| m.kind == MatchKind::Ranking).collect();
  let played = ranking.iter().filter(|m| m.state == MatchState::Finished).count();
  let behind = {
    let mut waiting: Vec<_> = matches.iter().filter(|m| m.state == MatchState::Scheduled).collect();
    waiting.sort_by_key(|m| m.scheduled_start);
    waiting
      .first()
      .map(|m| (now() - m.scheduled_start).num_minutes())
      .filter(|m| *m > 0)
  };
  let unscored = matches.iter().filter(|m| m.is_unscored()).count();
  let to_review = s
    .scoresheets
    .read()
    .iter()
    .filter(|x| x.status == ScoresheetStatus::Submitted)
    .count();
  let slots: Vec<_> = s
    .sessions
    .read()
    .iter()
    .flat_map(|x| x.slots.clone())
    .filter(|x| x.team_id.is_some())
    .collect();
  let judged = slots
    .iter()
    .filter(|x| matches!(x.queue, QueueState::Done | QueueState::NoShow))
    .count();
  let rubrics_waiting = s
    .rubrics
    .read()
    .iter()
    .filter(|r| r.status == RubricStatus::Submitted)
    .count();
  let stations = s.tables.read().len() + s.pods.read().len();
  let connected = s
    .presence
    .read()
    .iter()
    .filter(|p| p.table_id.is_some() || p.pod_id.is_some())
    .count();
  let errors = s
    .issues
    .read()
    .iter()
    .filter(|i| i.severity == IssueSeverity::Error)
    .count();
  let percent = |done: usize, all: usize| u32::try_from(done * 100 / all.max(1)).unwrap_or(100);

  rsx! {
    Card { title: "Event health",
      div { class: "grid gap-3 sm:grid-cols-2 xl:grid-cols-3", "data-testid": "event-health",
        Kpi {
          label: "Robot game",
          value: "{played} / {ranking.len()}",
          detail: "ranking matches played",
          progress: Some(percent(played, ranking.len())),
        }
        Kpi {
          label: "Pace",
          value: behind.map_or_else(|| "On time".to_owned(), |m| format!("{m} min")),
          detail: if behind.is_some() { "behind the schedule" } else { "matches are keeping to time" },
          tone: match behind { Some(m) if m >= 10 => Tone::Danger, Some(_) => Tone::Warning, None => Tone::Success },
        }
        Kpi {
          label: "Scoresheets",
          value: "{unscored + to_review}",
          detail: "{unscored} match(es) waiting for a sheet, {to_review} to review",
          tone: if unscored + to_review > 0 { Tone::Warning } else { Tone::Success },
        }
        Kpi {
          label: "Judging",
          value: "{judged} / {slots.len()}",
          detail: "{rubrics_waiting} rubric set(s) to review",
          progress: Some(percent(judged, slots.len())),
          tone: if rubrics_waiting > 0 { Tone::Warning } else { Tone::Neutral },
        }
        Kpi {
          label: "Station devices",
          value: "{connected} / {stations}",
          detail: "tables and pods with a tablet connected",
          tone: if connected < stations { Tone::Warning } else { Tone::Success },
        }
        Kpi {
          label: "Schedule",
          value: if errors == 0 { "OK".to_owned() } else { errors.to_string() },
          detail: if errors == 0 { "no schedule errors" } else { "schedule error(s); see Event setup → Schedule" },
          tone: if errors == 0 { Tone::Success } else { Tone::Danger },
        }
      }
    }
  }
}

/// What is on the field now and what comes next, with the clock, for the admin's overview.
#[component]
fn RightNow() -> Element {
  use_subscription(Topic::Timer);
  let realtime = use_context::<Realtime>();
  let timezone = realtime
    .stores
    .event
    .read()
    .as_ref()
    .map_or_else(|| "UTC".to_owned(), |e| e.timezone.clone());
  let matches = sorted_matches(&realtime.stores.matches.read());
  let field: Vec<String> = matches
    .iter()
    .filter(|m| matches!(m.state, MatchState::Staged | MatchState::Running))
    .map(GameMatch::label)
    .collect();
  let next = matches.iter().find(|m| m.state == MatchState::Scheduled).cloned();
  rsx! {
    Card {
      title: "Robot game now",
      actions: rsx! {
        Link { to: Route::MatchControl {}, class: "text-sm font-semibold text-primary hover:underline", "Match control →" }
      },
      div { class: "flex flex-wrap items-center justify-between gap-4",
        TimerClock { timer: realtime.stores.timer.read().clone(), size_class: "text-5xl" }
        div { class: "text-sm",
          p {
            span { class: "text-muted", "On the field: " }
            span { class: "font-semibold", if field.is_empty() { "nothing staged" } else { "{field.join(\", \")}" } }
          }
          if let Some(m) = next {
            p {
              span { class: "text-muted", "Next: " }
              span { class: "font-semibold", "{m.label()} at {format_time(m.scheduled_start, &timezone)}" }
            }
          }
        }
      }
    }
  }
}

/// Every table and pod with its device: connected or not, and anything it still holds.
#[component]
fn Stations() -> Element {
  let realtime = use_context::<Realtime>();
  let presence = realtime.stores.presence.read().clone();
  let mut tables = realtime.stores.tables.read().clone();
  tables.sort_by_key(|t| t.sort_order);
  let mut pods = realtime.stores.pods.read().clone();
  pods.sort_by_key(|p| p.sort_order);
  let places: Vec<(String, Option<Presence>)> = tables
    .iter()
    .map(|t| {
      (
        format!("{} table", t.name),
        presence.iter().find(|p| p.table_id == Some(t.id)).cloned(),
      )
    })
    .chain(pods.iter().map(|p| {
      (
        p.name.clone(),
        presence.iter().find(|d| d.pod_id == Some(p.id)).cloned(),
      )
    }))
    .collect();
  let unbound: Vec<Presence> = presence
    .iter()
    .filter(|p| p.table_id.is_none() && p.pod_id.is_none())
    .cloned()
    .collect();
  rsx! {
    Card { title: "Station devices",
      ul { class: "flex flex-col text-sm", "data-testid": "stations-list",
        for (place , device) in places {
          li { class: "flex items-center justify-between gap-3 border-b border-line py-2 last:border-b-0",
            span { class: "font-medium", "{place}" }
            div { class: "flex flex-wrap justify-end gap-1.5",
              match device {
                  Some(d) => rsx! {
                    if d.waiting > 0 {
                      Badge { tone: Tone::Warning, "{d.waiting} waiting to send" }
                    }
                    Badge { tone: Tone::Success, "Online" }
                  },
                  None => rsx! { Badge { tone: Tone::Danger, "No device" } },
              }
            }
          }
        }
        for d in unbound {
          li { class: "flex items-center justify-between gap-3 border-b border-line py-2 last:border-b-0",
            span { class: "font-medium", "{d.label}" }
            Badge { tone: Tone::Success, "{d.role.label()} key, online" }
          }
        }
      }
    }
  }
}

/// Announcements shown across the top of every logged-in device, such as "Lunch is running 15 minutes late".
#[component]
fn Announcements(event_id: Uuid) -> Element {
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let mut message = use_signal(String::new);
  let mut urgent = use_signal(|| false);
  let mut error = use_signal(|| None::<ApiFailure>);
  let banners = realtime.stores.banners.read().clone();
  let post = move |_| async move {
    error.set(None);
    let body = CreateBannerRequest {
      severity: if urgent() {
        BannerSeverity::Warning
      } else {
        BannerSeverity::Info
      },
      message: message().trim().to_owned(),
    };
    match api::post::<_, Banner>(&format!("/events/{event_id}/banners"), token(session).as_deref(), &body).await {
      Ok(_) => message.set(String::new()),
      Err(e) => error.set(Some(e)),
    }
  };
  rsx! {
    Card { title: "Announcements",
      p { class: "mb-3 text-sm text-muted", "Shown across the top of every logged-in device until cleared." }
      ul { class: "mb-3 flex flex-col",
        for b in banners {
          {
              let id = b.id;
              rsx! {
                li { key: "{b.id}", class: "flex items-center justify-between gap-3 border-b border-line py-2 text-sm last:border-b-0",
                  span { "{b.message}" }
                  Button {
                    size: ButtonSize::Small,
                    variant: ButtonVariant::Ghost,
                    onclick: move |_| async move {
                        if let Err(e) = api::post_empty(&format!("/banners/{id}/clear"), token(session).as_deref(), &()).await {
                            error.set(Some(e));
                        }
                    },
                    "Clear"
                  }
                }
              }
          }
        }
      }
      div { class: "flex flex-col gap-2",
        TextField { label: "New announcement", value: message(), placeholder: "Lunch is running 15 minutes late", oninput: move |v| message.set(v) }
        div { class: "flex items-center justify-between gap-2",
          Checkbox { label: "Show as a warning", checked: urgent(), onchange: move |v| urgent.set(v) }
          Button { disabled: message().trim().is_empty(), onclick: post, "Announce" }
        }
      }
      if let Some(e) = error() {
        div { class: "mt-3", ErrorBox { error: e } }
      }
    }
  }
}
