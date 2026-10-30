//! The awards ceremony: the venue screen, which shows only what has been revealed, and the controls the emcee or
//! judge advisor reveals each award with.

use dioxus::prelude::*;
use tms_core::Topic;
use tms_core::deliberation::{Ceremony, CeremonySlide};
use tms_ui::{Button, ButtonSize, ButtonVariant, Card};

use crate::components::{ErrorBox, token};
use crate::net::api::{self, ApiFailure};
use crate::net::realtime::{Realtime, use_subscription};
use crate::pages::game::DisplayFrame;
use crate::store::session::Session;

#[component]
pub fn AwardsDisplay() -> Element {
  use_subscription(Topic::Ceremony);
  let realtime = use_context::<Realtime>();
  let ceremony = realtime.stores.ceremony.read().clone();
  let slide = ceremony.as_ref().and_then(|c| c.slides.last().cloned());
  rsx! {
    DisplayFrame { title: "Awards",
      div { class: "flex flex-1 flex-col items-center justify-center gap-8 text-center", "data-testid": "awards-display",
        match slide {
            Some(slide) => rsx! {
              div { key: "{slide.title}", class: "tms-rise", Slide { slide, large: true } }
            },
            None => rsx! { h1 { class: "text-7xl font-extrabold tracking-tight", "Awards ceremony" } },
        }
      }
      if let Some(c) = ceremony.filter(|c| c.total > 0) {
        p { class: "text-right text-lg text-muted", "{c.shown} of {c.total}" }
      }
    }
  }
}

#[component]
fn Slide(slide: CeremonySlide, large: bool) -> Element {
  let (title, team, name) = if large {
    ("text-6xl", "text-5xl", "text-3xl")
  } else {
    ("text-xl", "text-lg", "text-sm")
  };
  rsx! {
    div { class: "flex flex-col items-center gap-4",
      h1 { class: "{title} font-bold", "{slide.title}" }
      ul { class: "flex flex-col gap-3",
        for w in slide.winners {
          li { class: "flex flex-col items-center",
            if !w.place.is_empty() {
              span { class: "text-sm font-semibold uppercase tracking-wide text-muted", "{w.place}" }
            }
            span { class: "{team} font-bold", "{w.team_number}" }
            span { class: "{name}", "{w.team_name}" }
          }
        }
      }
    }
  }
}

/// Reveals the ceremony one slide at a time; shows what comes next so it can be read out.
#[component]
pub fn CeremonyControls() -> Element {
  use_subscription(Topic::Ceremony);
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let error = use_signal(|| None::<ApiFailure>);
  let event_id = realtime.stores.event.read().as_ref().map(|e| e.id);
  let ceremony = realtime.stores.ceremony.read().clone();
  let script = use_resource(move || async move {
    let finalized = realtime.stores.ceremony.read().as_ref().map(|c| c.total);
    let event_id = realtime.stores.event.peek().as_ref().map(|e| e.id)?;
    finalized?;
    api::get::<Vec<CeremonySlide>>(
      &format!("/events/{event_id}/ceremony/script"),
      token(session).as_deref(),
    )
    .await
    .ok()
  });
  let Some(Ceremony { shown, total, .. }) = ceremony else {
    return rsx! {};
  };
  let act = move |action: &'static str| async move {
    let Some(event_id) = event_id else { return };
    let mut error = error;
    error.set(None);
    if let Err(e) = api::post::<_, Ceremony>(
      &format!("/events/{event_id}/ceremony/{action}"),
      token(session).as_deref(),
      &(),
    )
    .await
    {
      error.set(Some(e));
    }
  };
  let next = script
    .read()
    .clone()
    .flatten()
    .and_then(|s| s.get(shown as usize).cloned());
  rsx! {
    Card { title: "Awards ceremony",
      if total == 0 {
        p { class: "text-sm text-muted", "The ceremony starts once the judge advisor finalizes deliberation." }
      } else {
        p { class: "mb-3 text-sm", "data-testid": "ceremony-progress", "Shown {shown} of {total} on the awards screen." }
        div { class: "mb-3 flex flex-wrap gap-2",
          Button { size: ButtonSize::Large, variant: ButtonVariant::Primary, disabled: shown >= total, onclick: move |_| act("next"), "Reveal next" }
          Button { variant: ButtonVariant::Secondary, disabled: shown == 0, onclick: move |_| act("previous"), "Back" }
          Button { variant: ButtonVariant::Ghost, disabled: shown == 0, onclick: move |_| act("restart"), "Start over" }
        }
        if let Some(slide) = next {
          div { class: "rounded-control border border-line bg-surface-2 p-3",
            p { class: "mb-2 text-xs font-semibold uppercase tracking-wide text-muted", "Up next" }
            Slide { slide, large: false }
          }
        }
      }
      if let Some(e) = error() {
        div { class: "mt-3", ErrorBox { error: e } }
      }
    }
  }
}
