//! Printables: PDFs for the day, made by the server.

use dioxus::prelude::*;
use tms_core::Role;
use tms_core::role::has_role;
use tms_ui::{Button, ButtonVariant, Card};

use crate::components::{ErrorBox, NeedsActiveEvent, PageHeader, token};
use crate::net::api::{self, ApiFailure};
use crate::net::realtime::Realtime;
use crate::store::session::Session;

/// File name, title, what it is, and who may print it (the server checks the same).
const PRINTABLES: [(&str, &str, &str, Role); 8] = [
  (
    "team-schedules",
    "Team schedules",
    "One page per team with every match, judging session and timetable item, for the check-in packs.",
    Role::Admin,
  ),
  (
    "match-schedule",
    "Match schedule",
    "Every match with the team at each table.",
    Role::Admin,
  ),
  (
    "judging-schedule",
    "Judging schedule",
    "Every judging session with the team in each pod.",
    Role::Admin,
  ),
  (
    "table-signs",
    "Table signs",
    "A large sign for each competition table.",
    Role::Admin,
  ),
  (
    "pod-signs",
    "Pod signs",
    "A large sign for each judging pod and its room.",
    Role::Admin,
  ),
  (
    "scoresheets",
    "Paper scoresheets",
    "One per team per match, with the match, table and team filled in, for when a tablet isn't available.",
    Role::HeadReferee,
  ),
  (
    "rankings",
    "Robot game ranking",
    "The current ranking with every round's score.",
    Role::HeadReferee,
  ),
  (
    "certificates",
    "Award certificates",
    "One for each award winner and advancing team, from deliberation.",
    Role::JudgeAdvisor,
  ),
];

#[component]
pub fn Print() -> Element {
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let error = use_signal(|| None::<ApiFailure>);
  let busy = use_signal(|| None::<&'static str>);
  let Some(event) = realtime.stores.event.read().clone() else {
    return rsx! { PageHeader { title: "Print" } NeedsActiveEvent {} };
  };
  let roles = session.read().roles();
  let event_id = event.id;
  rsx! {
    PageHeader { title: "Print", subtitle: "PDFs made from what TMS holds now. Print again after the schedule changes." }
    if let Some(e) = error() {
      div { class: "mb-3", ErrorBox { error: e } }
    }
    div { class: "grid gap-3 md:grid-cols-2 xl:grid-cols-3", "data-testid": "printables",
      for (name , title , about , _) in PRINTABLES.into_iter().filter(|p| has_role(&roles, p.3)) {
        {
            let code = event.code.clone();
            rsx! {
              Card { key: "{name}", title,
                p { class: "mb-3 min-h-10 text-sm text-muted", "{about}" }
                Button {
                  variant: ButtonVariant::Primary,
                  loading: busy() == Some(name),
                  onclick: move |_| {
                      let code = code.clone();
                      let (mut error, mut busy) = (error, busy);
                      async move {
                          error.set(None);
                          busy.set(Some(name));
                          let path = format!("/events/{event_id}/print/{name}.pdf");
                          if let Err(e) = api::download(&path, token(session).as_deref(), &format!("{code}-{name}.pdf")).await {
                              error.set(Some(e));
                          }
                          busy.set(None);
                      }
                  },
                  "Download PDF"
                }
              }
            }
        }
      }
    }
  }
}
