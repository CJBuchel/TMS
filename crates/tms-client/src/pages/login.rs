use dioxus::prelude::*;
use tms_core::Topic;
use tms_core::access_key;
use tms_core::dto::{AuthResponse, KeyLoginRequest, LoginRequest};
use tms_ui::{Button, ButtonSize, Card, Tab, Tabs, TextField};

use crate::net::api::{self, ApiFailure};
use crate::net::realtime::{Realtime, use_subscription};
use crate::pages::game::venue_screens;
use crate::routes::Route;
use crate::store::session::{Session, SessionState};

#[derive(Clone, Copy, PartialEq)]
enum Mode {
  Password,
  Key,
}

/// The login page. `?access=` (from an access key's QR code) logs straight in with that key.
#[component]
pub fn Login(access: String) -> Element {
  use_subscription(Topic::Event);
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let mut mode = use_signal(|| if access.is_empty() { Mode::Password } else { Mode::Key });

  use_effect(move || {
    if session.read() != SessionState::LoggedOut {
      navigator().replace(Route::Home {});
    }
  });

  let event = realtime.stores.event.read().clone();

  rsx! {
    div { class: "flex min-h-screen items-start justify-center bg-bg px-4 pt-[10vh]",
      div { class: "w-full max-w-sm",
        div { class: "mb-5",
          span { class: "mb-4 inline-flex h-10 items-center rounded-control bg-primary px-3 text-sm font-extrabold tracking-wider text-on-primary shadow-sm", "TMS" }
          h1 { class: "text-3xl font-bold tracking-tight", "Login" }
          match event {
            Some(e) => rsx! { p { class: "text-sm text-muted", "{e.name} · {e.code}" } },
            None => rsx! { p { class: "text-sm text-muted", "TMS" } },
          }
        }
        Card {
          div { class: "mb-4 [&>div]:grid [&>div]:w-full [&>div]:grid-cols-2",
            Tabs {
              Tab { active: mode() == Mode::Password, onclick: move |_| mode.set(Mode::Password), "Password" }
              Tab { active: mode() == Mode::Key, onclick: move |_| mode.set(Mode::Key), "Access key" }
            }
          }
          match mode() {
            Mode::Password => rsx! { PasswordForm {} },
            Mode::Key => rsx! { KeyForm { initial: access.clone() } },
          }
        }
        nav { class: "mt-8", "data-testid": "venue-screens",
          h2 { class: "mb-2 text-xs font-semibold uppercase tracking-wider text-muted", "Venue screens · no login needed" }
          div { class: "flex flex-wrap gap-2",
            for (to , name , _) in venue_screens() {
              Link { to, class: "rounded-full border border-line bg-surface px-3.5 py-1.5 text-sm font-semibold shadow-sm hover:border-primary hover:text-primary", "{name}" }
            }
          }
        }
      }
    }
  }
}

#[component]
fn PasswordForm() -> Element {
  let realtime = use_context::<Realtime>();
  let mut session = use_context::<Session>();
  let mut username = use_signal(String::new);
  let mut password = use_signal(String::new);
  let mut error = use_signal(|| None::<String>);
  let mut busy = use_signal(|| false);

  let submit = move |e: FormEvent| async move {
    e.prevent_default();
    busy.set(true);
    error.set(None);
    let body = LoginRequest {
      username: username().trim().to_lowercase(),
      password: password(),
    };
    match api::post::<_, AuthResponse>("/auth/login", None, &body).await {
      Ok(auth) => {
        session.set(SessionState::from_auth(auth, None));
        realtime.reconnect();
        navigator().replace(Route::Home {});
      }
      Err(ApiFailure::Api { code, .. }) if code == "auth.invalid_credentials" => {
        error.set(Some("Wrong username or password.".into()));
      }
      Err(e) => error.set(Some(e.message())),
    }
    busy.set(false);
  };

  rsx! {
    form { class: "flex flex-col gap-3", onsubmit: submit,
      TextField { label: "Username", value: username(), autocomplete: "username", autofocus: true, oninput: move |v| username.set(v) }
      TextField { label: "Password", r#type: "password", value: password(), autocomplete: "current-password", oninput: move |v| password.set(v) }
      if let Some(message) = error() {
        p { role: "alert", class: "rounded-control border border-danger bg-danger-soft px-3 py-2 text-sm text-danger-strong", "{message}" }
      }
      Button { r#type: "submit", size: ButtonSize::Large, full_width: true, loading: busy(), disabled: username().trim().is_empty() || password().is_empty(), "Log in" }
      p { class: "text-sm text-muted", "Logging in with a password needs the server. An access key also works offline." }
    }
  }
}

#[component]
fn KeyForm(initial: String) -> Element {
  let realtime = use_context::<Realtime>();
  let mut session = use_context::<Session>();
  let auto = !initial.is_empty();
  let mut key = use_signal(|| initial);
  let mut error = use_signal(|| None::<String>);
  let mut busy = use_signal(|| false);

  let log_in = move || async move {
    error.set(None);
    let Some(parsed) = access_key::parse(&key()) else {
      error.set(Some(
        "That is not a valid access key. It looks like REF-XXXX-XXXX-XXXX.".into(),
      ));
      return;
    };
    busy.set(true);
    let body = KeyLoginRequest {
      key: parsed.normalized.clone(),
    };
    match api::post::<_, AuthResponse>("/auth/key", None, &body).await {
      Ok(auth) => {
        session.set(SessionState::from_auth(auth, Some(parsed.normalized)));
        realtime.reconnect();
        navigator().replace(Route::Home {});
      }
      // No server: trust the key's role prefix for now. The reconnect verifies it as soon as the server answers,
      // even if a public live-feed connection is already open.
      Err(ApiFailure::Network(_)) => {
        session.set(SessionState::OfflineKey {
          key: parsed.normalized,
          role: parsed.role,
          rejected: false,
        });
        realtime.reconnect();
        navigator().replace(Route::Home {});
      }
      Err(ApiFailure::Api { status: 401, .. }) => {
        error.set(Some("This key is not recognised, has expired or was revoked.".into()));
      }
      Err(e) => error.set(Some(e.message())),
    }
    busy.set(false);
  };
  let submit = move |e: FormEvent| async move {
    e.prevent_default();
    log_in().await;
  };
  use_hook(move || {
    if auto {
      spawn(log_in());
    }
  });

  let preview = access_key::parse(&key()).map(|p| p.role.label());
  rsx! {
    form { class: "flex flex-col gap-3", onsubmit: submit,
      TextField {
        label: "Access key",
        value: key(),
        placeholder: "REF-XXXX-XXXX-XXXX",
        autocomplete: "off",
        autofocus: true,
        mono: true,
        hint: preview.map(|r| format!("Logs in as {r}")),
        oninput: move |v| key.set(v),
      }
      if let Some(message) = error() {
        p { role: "alert", class: "rounded-control border border-danger bg-danger-soft px-3 py-2 text-sm text-danger-strong", "{message}" }
      }
      Button { r#type: "submit", size: ButtonSize::Large, full_width: true, loading: busy(), disabled: key().trim().is_empty(), "Log in" }
      p { class: "text-sm text-muted", "Access keys are created by an admin for a device or station. If the server is unreachable the device starts offline and checks the key later." }
    }
  }
}
