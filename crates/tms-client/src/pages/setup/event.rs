use chrono::NaiveDate;
use dioxus::prelude::*;
use tms_core::dto::{CreateEventRequest, EventStatus, EventSummary, Season, UpdateEventRequest};
use tms_core::model::{EventSettings, RubricReview, ScoresheetReview};
use tms_ui::{Badge, Button, ButtonVariant, Card, Checkbox, DataTable, Select, TextField, Tone};

use crate::components::{ConfirmButton, ErrorBox, PageHeader, SuccessBox, token};
use crate::net::api::{self, ApiFailure};
use crate::net::realtime::Realtime;
use crate::store::session::Session;
use crate::time::device_timezone;

fn status_tone(status: EventStatus) -> Tone {
  match status {
    EventStatus::Active => Tone::Success,
    EventStatus::Draft => Tone::Neutral,
    EventStatus::Archived => Tone::Warning,
  }
}

#[component]
pub fn SetupEvent() -> Element {
  let session = use_context::<Session>();
  let realtime = use_context::<Realtime>();
  // Bumped after any change so the list reloads.
  let mut version = use_signal(|| 0_u32);
  let events = use_resource(move || async move {
    let _ = version();
    api::get::<Vec<EventSummary>>("/events", token(session).as_deref()).await
  });
  let seasons =
    use_resource(move || async move { api::get::<Vec<Season>>("/seasons", None).await.unwrap_or_default() });
  let mut error = use_signal(|| None::<ApiFailure>);

  let act = move |path: String| async move {
    error.set(None);
    if let Err(e) = api::post::<_, EventSummary>(&path, token(session).as_deref(), &()).await {
      error.set(Some(e));
    }
    version += 1;
  };

  let active = realtime.stores.event.read().clone();
  let season_list = seasons.read().clone().unwrap_or_default();

  rsx! {
    PageHeader { title: "Event", subtitle: "Create events, choose the active one, and set its rules." }
    div { class: "grid gap-4 xl:grid-cols-2",
      div { class: "flex flex-col gap-4",
        Card { title: "Events",
          if let Some(e) = error() {
            div { class: "mb-3", ErrorBox { error: e } }
          }
          match &*events.read() {
            None => rsx! { p { class: "text-sm text-muted", "Loading…" } },
            Some(Err(e)) => rsx! { ErrorBox { error: e.clone() } },
            Some(Ok(list)) => rsx! {
              DataTable {
                columns: vec!["Code".into(), "Name".into(), "Dates".into(), "Status".into(), String::new()],
                empty: "No events yet. Create one below.",
                rows: list
                    .iter()
                    .map(|e| {
                        let id = e.id;
                        let status = e.status;
                        rsx! {
                          tr {
                            td { class: "font-mono whitespace-nowrap", "{e.code}" }
                            td { "{e.name}" }
                            td { class: "whitespace-nowrap", "{e.starts_on} – {e.ends_on}" }
                            td {
                              Badge { tone: status_tone(status), "{status.label()}" }
                            }
                            td { class: "text-right whitespace-nowrap",
                              if status == EventStatus::Draft {
                                ConfirmButton {
                                  label: "Activate",
                                  variant: ButtonVariant::Primary,
                                  title: "Make {e.name} the active event?",
                                  message: "Every screen and display switches to this event. The current active event goes back to draft.",
                                  confirm_label: "Activate",
                                  onconfirm: move |()| { spawn(act(format!("/events/{id}/activate"))); },
                                }
                              }
                              if status != EventStatus::Archived {
                                ConfirmButton {
                                  label: "Archive",
                                  title: "Archive {e.name}?",
                                  message: "The event ends: it is no longer active, every access key for it is revoked, and devices using those keys are logged out. Its data is kept.",
                                  confirm_label: "Archive event",
                                  onconfirm: move |()| { spawn(act(format!("/events/{id}/archive"))); },
                                }
                              }
                            }
                          }
                        }
                    })
                    .collect(),
              }
            },
          }
        }
        CreateEvent { seasons: season_list.clone(), oncreated: move |()| version += 1 }
      }
      match active {
        Some(event) => rsx! { EditEvent { key: "{event.id}", event, seasons: season_list } },
        None => rsx! {
          Card { title: "Active event", p { class: "text-sm text-muted", "No event is active. Activate one to edit its details and rules." } }
        },
      }
    }
  }
}

#[component]
fn CreateEvent(seasons: Vec<Season>, oncreated: EventHandler<()>) -> Element {
  let session = use_context::<Session>();
  let mut code = use_signal(String::new);
  let mut name = use_signal(String::new);
  let mut season = use_signal(String::new);
  let mut timezone = use_signal(device_timezone);
  let mut starts = use_signal(String::new);
  let mut ends = use_signal(String::new);
  let mut error = use_signal(|| None::<ApiFailure>);
  let mut created = use_signal(|| None::<String>);
  let mut busy = use_signal(|| false);

  let season_value = if season().is_empty() {
    seasons.first().map(|s| s.id.clone()).unwrap_or_default()
  } else {
    season()
  };
  let options: Vec<(String, String)> = seasons.iter().map(|s| (s.id.clone(), s.name.clone())).collect();

  let season_for_submit = season_value.clone();
  let submit = move |e: FormEvent| {
    let season_id = season_for_submit.clone();
    async move {
      e.prevent_default();
      error.set(None);
      created.set(None);
      let (Ok(starts_on), Ok(ends_on)) = (starts().parse::<NaiveDate>(), ends().parse::<NaiveDate>()) else {
        error.set(Some(ApiFailure::Api {
          status: 0,
          code: "input".into(),
          message: "Choose a start and end date.".into(),
          details: vec![],
        }));
        return;
      };
      busy.set(true);
      let body = CreateEventRequest {
        code: code(),
        name: name(),
        season_id,
        timezone: timezone(),
        starts_on,
        ends_on,
      };
      match api::post::<_, EventSummary>("/events", token(session).as_deref(), &body).await {
        Ok(event) => {
          created.set(Some(format!(
            "Created {}. Activate it to start setting it up.",
            event.name
          )));
          code.set(String::new());
          name.set(String::new());
          oncreated.call(());
        }
        Err(e) => error.set(Some(e)),
      }
      busy.set(false);
    }
  };

  rsx! {
    Card { title: "New event",
      form { class: "grid gap-3 sm:grid-cols-2", onsubmit: submit,
        TextField { label: "Code", value: code(), placeholder: "SYD-26", hint: "Printed on scoresheets. A-Z, 0-9 and '-'.", mono: true, oninput: move |v: String| code.set(v.to_uppercase()) }
        TextField { label: "Name", value: name(), placeholder: "Sydney Regional", oninput: move |v| name.set(v) }
        Select { label: "Season", value: season_value.clone(), options, onchange: move |v| season.set(v) }
        TextField { label: "Timezone", value: timezone(), hint: "IANA name, such as Australia/Sydney.", oninput: move |v| timezone.set(v) }
        TextField { label: "First day", r#type: "date", value: starts(), oninput: move |v| starts.set(v) }
        TextField { label: "Last day", r#type: "date", value: ends(), oninput: move |v| ends.set(v) }
        div { class: "flex flex-col gap-2 sm:col-span-2",
          if let Some(e) = error() {
            ErrorBox { error: e }
          }
          if let Some(message) = created() {
            SuccessBox { message }
          }
          div {
            Button { r#type: "submit", loading: busy(), disabled: code().trim().is_empty() || name().trim().is_empty(), "Create event" }
          }
        }
      }
    }
  }
}

/// Text fields for the numeric settings, parsed on save.
#[derive(Clone, PartialEq)]
struct SettingsForm {
  match_seconds: String,
  endgame_seconds: String,
  countdown_seconds: String,
  ranking_rounds: String,
  practice_rounds: String,
  judging_session_minutes: String,
  judging_buffer_minutes: String,
  judging_match_gap_minutes: String,
  queue_call_minutes: String,
  queue_soon_minutes: String,
  advancement_slots: String,
}

impl SettingsForm {
  fn from(s: &EventSettings) -> Self {
    Self {
      match_seconds: s.match_seconds.to_string(),
      endgame_seconds: s.endgame_seconds.to_string(),
      countdown_seconds: s.countdown_seconds.to_string(),
      ranking_rounds: s.ranking_rounds.to_string(),
      practice_rounds: s.practice_rounds.to_string(),
      judging_session_minutes: s.judging_session_minutes.to_string(),
      judging_buffer_minutes: s.judging_buffer_minutes.to_string(),
      judging_match_gap_minutes: s.judging_match_gap_minutes.to_string(),
      queue_call_minutes: s.queue_call_minutes.to_string(),
      queue_soon_minutes: s.queue_soon_minutes.to_string(),
      advancement_slots: s.advancement_slots.to_string(),
    }
  }

  fn apply(&self, base: &EventSettings) -> Result<EventSettings, String> {
    fn num<T: std::str::FromStr>(value: &str, what: &str) -> Result<T, String> {
      value
        .trim()
        .parse()
        .map_err(|_| format!("{what} must be a whole number."))
    }
    Ok(EventSettings {
      match_seconds: num(&self.match_seconds, "Match length")?,
      endgame_seconds: num(&self.endgame_seconds, "End game")?,
      countdown_seconds: num(&self.countdown_seconds, "Countdown")?,
      ranking_rounds: num(&self.ranking_rounds, "Ranking rounds")?,
      practice_rounds: num(&self.practice_rounds, "Practice rounds")?,
      judging_session_minutes: num(&self.judging_session_minutes, "Judging session length")?,
      judging_buffer_minutes: num(&self.judging_buffer_minutes, "Judging buffer")?,
      judging_match_gap_minutes: num(&self.judging_match_gap_minutes, "Gap between judging and matches")?,
      queue_call_minutes: num(&self.queue_call_minutes, "Queue now")?,
      queue_soon_minutes: num(&self.queue_soon_minutes, "Soon")?,
      advancement_slots: num(&self.advancement_slots, "Teams advancing")?,
      ..base.clone()
    })
  }
}

#[component]
fn EditEvent(event: EventSummary, seasons: Vec<Season>) -> Element {
  let session = use_context::<Session>();
  let mut name = use_signal(|| event.name.clone());
  let mut season = use_signal(|| event.season_id.clone());
  let mut timezone = use_signal(|| event.timezone.clone());
  let mut starts = use_signal(|| event.starts_on.to_string());
  let mut ends = use_signal(|| event.ends_on.to_string());
  let mut form = use_signal(|| SettingsForm::from(&event.settings));
  let mut review = use_signal(|| event.settings.scoresheet_review);
  let mut gp_comment = use_signal(|| event.settings.gp_comment_required);
  let mut agreement = use_signal(|| event.settings.team_agreement_required);
  let mut needs_ready = use_signal(|| event.settings.start_needs_ready);
  let mut rubric_review = use_signal(|| event.settings.rubric_review);
  let mut error = use_signal(|| None::<ApiFailure>);
  let mut saved = use_signal(|| false);
  let mut busy = use_signal(|| false);
  let base = event.settings.clone();
  let id = event.id;

  let submit = move |e: FormEvent| {
    let base = base.clone();
    async move {
      e.prevent_default();
      error.set(None);
      saved.set(false);
      let input = |message: String| ApiFailure::Api {
        status: 0,
        code: "input".into(),
        message,
        details: vec![],
      };
      let settings = match form().apply(&base) {
        Ok(s) => EventSettings {
          scoresheet_review: review(),
          gp_comment_required: gp_comment(),
          team_agreement_required: agreement(),
          start_needs_ready: needs_ready(),
          rubric_review: rubric_review(),
          ..s
        },
        Err(message) => return error.set(Some(input(message))),
      };
      let (Ok(starts_on), Ok(ends_on)) = (starts().parse::<NaiveDate>(), ends().parse::<NaiveDate>()) else {
        return error.set(Some(input("Choose a start and end date.".into())));
      };
      busy.set(true);
      let body = UpdateEventRequest {
        name: name(),
        season_id: season(),
        timezone: timezone(),
        starts_on,
        ends_on,
        settings,
      };
      match api::patch::<_, EventSummary>(&format!("/events/{id}"), token(session).as_deref(), &body).await {
        Ok(_) => saved.set(true),
        Err(e) => error.set(Some(e)),
      }
      busy.set(false);
    }
  };

  let options: Vec<(String, String)> = seasons.iter().map(|s| (s.id.clone(), s.name.clone())).collect();
  let review_options = vec![
    (
      "auto".to_owned(),
      "Count straight away (head referee sees flagged sheets)".to_owned(),
    ),
    ("review".to_owned(), "Head referee approves every sheet".to_owned()),
  ];
  let review_key = if review() == ScoresheetReview::AutoPublish {
    "auto"
  } else {
    "review"
  };
  let field = |label: &'static str, value: String, hint: &'static str, set: fn(&mut SettingsForm, String)| {
    rsx! {
      TextField {
        label,
        r#type: "number",
        value,
        hint,
        oninput: move |v| form.with_mut(|f| set(f, v)),
      }
    }
  };

  rsx! {
    Card { title: "Active event: {event.code}",
      form { class: "flex flex-col gap-4", onsubmit: submit,
        div { class: "grid gap-3 sm:grid-cols-2",
          TextField { label: "Name", value: name(), oninput: move |v| name.set(v) }
          Select { label: "Season", value: season(), options, onchange: move |v| season.set(v) }
          TextField { label: "Timezone", value: timezone(), oninput: move |v| timezone.set(v) }
          div {}
          TextField { label: "First day", r#type: "date", value: starts(), oninput: move |v| starts.set(v) }
          TextField { label: "Last day", r#type: "date", value: ends(), oninput: move |v| ends.set(v) }
        }
        h3 { class: "border-b border-line pb-1 text-sm font-semibold uppercase tracking-wide text-muted", "Robot game" }
        div { class: "grid gap-3 sm:grid-cols-3",
          {field("Match length (s)", form().match_seconds, "150 for 2:30", |f, v| f.match_seconds = v)}
          {field("End game starts (s left)", form().endgame_seconds, "", |f, v| f.endgame_seconds = v)}
          {field("Countdown (s)", form().countdown_seconds, "", |f, v| f.countdown_seconds = v)}
          {field("Ranking rounds", form().ranking_rounds, "", |f, v| f.ranking_rounds = v)}
          {field("Practice rounds", form().practice_rounds, "", |f, v| f.practice_rounds = v)}
        }
        Select {
          label: "Scoresheets",
          value: review_key,
          options: review_options,
          onchange: move |v: String| review.set(if v == "review" { ScoresheetReview::HeadRefereeReview } else { ScoresheetReview::AutoPublish }),
        }
        Checkbox { label: "Require a comment when Gracious Professionalism is not 3", checked: gp_comment(), onchange: move |v| gp_comment.set(v) }
        Checkbox { label: "Team confirms the scoresheet before it is submitted", checked: agreement(), onchange: move |v| agreement.set(v) }
        h3 { class: "border-b border-line pb-1 text-sm font-semibold uppercase tracking-wide text-muted", "Queueing" }
        Checkbox { label: "The match timer waits until every team is ready (the head referee can start anyway)", checked: needs_ready(), onchange: move |v| needs_ready.set(v) }
        div { class: "grid gap-3 sm:grid-cols-3",
          {field("Soon (min before)", form().queue_soon_minutes, "Teams show as Soon so queuers can find them", |f, v| f.queue_soon_minutes = v)}
          {field("Queue now (min before)", form().queue_call_minutes, "Teams should be queueing; half of this is Late", |f, v| f.queue_call_minutes = v)}
        }
        h3 { class: "border-b border-line pb-1 text-sm font-semibold uppercase tracking-wide text-muted", "Judging" }
        div { class: "grid gap-3 sm:grid-cols-3",
          {field("Session length (min)", form().judging_session_minutes, "", |f, v| f.judging_session_minutes = v)}
          {field("Rubric time after (min)", form().judging_buffer_minutes, "", |f, v| f.judging_buffer_minutes = v)}
          {field("Gap to matches (min)", form().judging_match_gap_minutes, "", |f, v| f.judging_match_gap_minutes = v)}
        }
        Select {
          label: "Rubrics",
          value: if rubric_review() == RubricReview::Auto { "auto" } else { "review" },
          options: vec![
              ("auto".to_owned(), "Count straight away (a second set for a team waits for review)".to_owned()),
              ("review".to_owned(), "Judge advisor approves every set".to_owned()),
          ],
          onchange: move |v: String| rubric_review.set(if v == "review" { RubricReview::JudgeAdvisorReview } else { RubricReview::Auto }),
        }
        h3 { class: "border-b border-line pb-1 text-sm font-semibold uppercase tracking-wide text-muted", "Awards" }
        div { class: "grid gap-3 sm:grid-cols-3",
          {field("Teams advancing", form().advancement_slots, "0 when no team advances", |f, v| f.advancement_slots = v)}
        }
        if let Some(e) = error() {
          ErrorBox { error: e }
        }
        if saved() {
          SuccessBox { message: "Saved." }
        }
        div {
          Button { r#type: "submit", loading: busy(), "Save event" }
        }
      }
    }
  }
}
