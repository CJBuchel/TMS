//! Building blocks shared by the app's pages (the generic visual pieces live in `tms-ui`).

use dioxus::prelude::*;
use tms_ui::{Button, ButtonSize, ButtonVariant, Modal};

use crate::net::api::ApiFailure;
use crate::store::session::Session;

/// The current login token, read without subscribing (for event handlers).
pub fn token(session: Session) -> Option<String> {
  session.peek().token().map(str::to_owned)
}

/// A failed request: the message, then each detail on its own line.
#[component]
pub fn ErrorBox(error: ApiFailure) -> Element {
  let details = error.details();
  rsx! {
    div { role: "alert", class: "rounded-control border border-danger bg-danger-soft px-3 py-2 text-sm text-danger-strong",
      p { class: "font-semibold", "{error.message()}" }
      if !details.is_empty() {
        ul { class: "mt-1 list-disc pl-5",
          for detail in details {
            li { "{detail}" }
          }
        }
      }
    }
  }
}

/// A success note, for results such as "Imported 60 matches".
#[component]
pub fn SuccessBox(message: String) -> Element {
  rsx! {
    div { role: "status", class: "rounded-control border border-success bg-success-soft px-3 py-2 text-sm text-success-strong", "{message}" }
  }
}

/// Page title with optional actions on the right, and an optional link back to the page this one belongs to.
#[component]
pub fn PageHeader(
  title: String,
  #[props(default)] subtitle: Option<String>,
  #[props(default)] actions: Option<Element>,
  #[props(default)] back: Option<(crate::routes::Route, String)>,
) -> Element {
  rsx! {
    div { class: "mb-5 flex flex-wrap items-end justify-between gap-3",
      div {
        if let Some((to, label)) = back {
          Link { to, class: "mb-1 inline-flex items-center gap-1 text-sm font-medium text-primary hover:underline", "← {label}" }
        }
        h1 { class: "text-2xl font-bold tracking-tight", "{title}" }
        if let Some(subtitle) = subtitle {
          p { class: "text-sm text-muted", "{subtitle}" }
        }
      }
      if let Some(actions) = actions {
        div { class: "flex flex-wrap items-center gap-2", {actions} }
      }
    }
  }
}

/// A button that asks before doing something destructive or far-reaching.
#[component]
pub fn ConfirmButton(
  label: String,
  title: String,
  message: String,
  confirm_label: String,
  #[props(default = ButtonVariant::Danger)] variant: ButtonVariant,
  #[props(default = ButtonSize::Small)] size: ButtonSize,
  #[props(default)] disabled: bool,
  onconfirm: EventHandler<()>,
) -> Element {
  let mut open = use_signal(|| false);
  let confirm_variant = match variant {
    ButtonVariant::DangerGhost => ButtonVariant::Danger,
    ButtonVariant::Ghost => ButtonVariant::Primary,
    v => v,
  };
  rsx! {
    Button { variant, size, disabled, onclick: move |_| open.set(true), "{label}" }
    if open() {
      Modal {
        title,
        onclose: move |()| open.set(false),
        footer: rsx! {
          Button { variant: ButtonVariant::Secondary, onclick: move |_| open.set(false), "Cancel" }
          Button {
            variant: confirm_variant,
            onclick: move |_| {
                open.set(false);
                onconfirm.call(());
            },
            "{confirm_label}"
          }
        },
        p { "{message}" }
      }
    }
  }
}

/// Shown on pages that need an active event when there is none.
#[component]
pub fn NeedsActiveEvent() -> Element {
  rsx! {
    div { class: "rounded-control border border-warning bg-warning-soft px-4 py-3 text-sm text-warning-strong",
      "No event is active. Create or activate one on the Event tab first."
    }
  }
}
