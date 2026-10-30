use dioxus::prelude::*;
use tms_core::dto::{AuthResponse, ChangePasswordRequest};
use tms_ui::{Button, ButtonSize, Card, TextField};

use crate::net::api;
use crate::net::realtime::Realtime;
use crate::store::session::{Session, SessionState};

const MIN_LEN: usize = 8;

/// Changes the logged-in user's password. `forced`: shown in place of every page until a one-time password is
/// changed; otherwise it is the form on the Settings page.
#[component]
pub fn ChangePassword(#[props(default = true)] forced: bool) -> Element {
  let realtime = use_context::<Realtime>();
  let mut session = use_context::<Session>();
  let mut current = use_signal(String::new);
  let mut new = use_signal(String::new);
  let mut confirm = use_signal(String::new);
  let mut error = use_signal(|| None::<String>);
  let mut busy = use_signal(|| false);
  let mut done = use_signal(|| false);

  let mismatch = !confirm().is_empty() && confirm() != new();
  let too_short = !new().is_empty() && new().chars().count() < MIN_LEN;

  let submit = move |e: FormEvent| async move {
    e.prevent_default();
    busy.set(true);
    error.set(None);
    let token = session.peek().token().map(str::to_owned);
    let body = ChangePasswordRequest {
      current_password: current(),
      new_password: new(),
    };
    // The server ends every older login for this user, including this one, and returns a fresh token.
    match api::post::<_, AuthResponse>("/auth/password", token.as_deref(), &body).await {
      Ok(auth) => {
        session.set(SessionState::from_auth(auth, None));
        realtime.reconnect();
        current.set(String::new());
        new.set(String::new());
        confirm.set(String::new());
        done.set(true);
      }
      Err(e) => error.set(Some(e.message())),
    }
    busy.set(false);
  };

  rsx! {
    div { class: "max-w-md",
      Card { title: "Change your password",
        form { class: "flex flex-col gap-3", onsubmit: submit,
          if forced {
            p { class: "text-sm text-muted", "This account has a temporary password. Choose a new one before continuing." }
          } else {
            p { class: "text-sm text-muted", "Your other logins end; this one carries on." }
          }
          if done() && !forced {
            p { role: "status", class: "rounded-control border border-success bg-success-soft px-3 py-2 text-sm text-success-strong", "Password changed." }
          }
          TextField { label: "Current password", r#type: "password", value: current(), autocomplete: "current-password", oninput: move |v| current.set(v) }
          TextField {
            label: "New password",
            r#type: "password",
            value: new(),
            autocomplete: "new-password",
            error: too_short.then(|| format!("Use at least {MIN_LEN} characters.")),
            oninput: move |v| new.set(v),
          }
          TextField {
            label: "Confirm new password",
            r#type: "password",
            value: confirm(),
            autocomplete: "new-password",
            error: mismatch.then(|| "Passwords do not match.".to_owned()),
            oninput: move |v| confirm.set(v),
          }
          if let Some(message) = error() {
            p { role: "alert", class: "rounded-control border border-danger bg-danger-soft px-3 py-2 text-sm text-danger-strong", "{message}" }
          }
          Button {
            r#type: "submit",
            size: ButtonSize::Large,
            loading: busy(),
            disabled: current().is_empty() || new().chars().count() < MIN_LEN || confirm() != new(),
            "Change password"
          }
        }
      }
    }
  }
}
