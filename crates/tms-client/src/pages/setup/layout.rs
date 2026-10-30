use dioxus::prelude::*;
use tms_core::role::has_role;
use tms_core::{Role, Topic};
use tms_ui::Card;

use crate::net::realtime::use_subscription;
use crate::routes::Route;
use crate::store::session::Session;

/// Every setup tab reads these live; holding them here means switching tabs never resubscribes.
const TOPICS: [Topic; 7] = [
  Topic::Event,
  Topic::Teams,
  Topic::Tables,
  Topic::Pods,
  Topic::Matches,
  Topic::JudgingSessions,
  Topic::Blocks,
];

#[component]
pub fn SetupLayout() -> Element {
  for topic in TOPICS {
    use_subscription(topic);
  }
  let session = use_context::<Session>();
  if !has_role(&session.read().roles(), Role::Admin) {
    return rsx! {
      Card { title: "Event setup", p { class: "text-sm", "Event setup is for admins." } }
    };
  }

  let tabs = [
    (Route::SetupEvent {}, "Event"),
    (Route::SetupTeams {}, "Teams"),
    (Route::SetupVenue {}, "Tables & pods"),
    (Route::SetupSchedule {}, "Schedule"),
    (Route::SetupAwards {}, "Awards"),
    (Route::SetupUsers {}, "Users"),
    (Route::SetupKeys {}, "Access keys"),
    (Route::SetupAudit {}, "Audit log"),
  ];
  let current = use_route::<Route>();
  rsx! {
    nav { class: "mb-5 flex w-fit max-w-full flex-wrap gap-1 rounded-panel bg-surface-2 p-1 ring-1 ring-line ring-inset",
      for (route , label) in tabs {
        Link {
          to: route.clone(),
          class: if route == current { "rounded-control bg-surface px-3 py-1.5 text-sm font-semibold shadow-sm" } else { "rounded-control px-3 py-1.5 text-sm text-muted hover:bg-surface/60 hover:text-fg" },
          "{label}"
        }
      }
    }
    Outlet::<Route> {}
  }
}
