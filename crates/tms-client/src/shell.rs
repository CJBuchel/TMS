//! The frame around every logged-in page: a slim top bar and one banner, with everything else in a menu that slides
//! out, so each device's own screen gets the whole width.

use dioxus::prelude::*;
use tms_core::dto::BannerSeverity;
use tms_core::role::has_role;
use tms_core::{Role, Topic};
use tms_ui::{Badge, Banner, Button, ButtonSize, ButtonVariant, Modal, Tone};

use crate::net::api;
use crate::net::realtime::{ConnStatus, Realtime, use_subscription};
use crate::pages::ChangePassword;
use crate::pages::game::venue_screens;
use crate::routes::Route;
use crate::store::session::{Session, SessionState};
use crate::store::theme::{Theme, ThemeMode};
use crate::time::format_clock;

#[component]
pub fn Shell() -> Element {
  // Every page under the shell shows the event name and banners, so the layout holds these topics.
  // Navigating between pages therefore never unsubscribes and resubscribes them.
  use_subscription(Topic::Event);
  use_subscription(Topic::Banners);

  let session = use_context::<Session>();
  let mut menu = use_signal(|| false);
  let state = session.read();
  use_effect(move || {
    if session.read() == SessionState::LoggedOut {
      navigator().replace(Route::Login { access: String::new() });
    }
  });
  if state == SessionState::LoggedOut {
    return rsx! {};
  }

  rsx! {
    div { class: "flex min-h-screen flex-col",
      TopBar { onmenu: move |()| menu.set(true) }
      BannerSlot {}
      main { class: "mx-auto w-full max-w-[1600px] min-w-0 flex-1 p-3 md:p-6",
        if state.must_change_password() {
          ChangePassword {}
        } else {
          Outlet::<Route> {}
        }
      }
    }
    if menu() {
      Menu { onclose: move |()| menu.set(false) }
    }
  }
}

#[component]
fn TopBar(onmenu: EventHandler<()>) -> Element {
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let event = realtime.stores.event.read().clone();
  let roles = session.read().roles();

  rsx! {
    header { class: "sticky top-0 z-30 flex h-12 items-center gap-3 border-b border-line bg-surface/85 px-2 backdrop-blur md:px-4",
      button {
        class: "flex items-center gap-2 rounded-control px-2.5 py-2 text-sm font-semibold hover:bg-surface-2",
        "data-testid": "menu-button",
        "aria-label": "Menu",
        onclick: move |_| onmenu.call(()),
        span { class: "flex flex-col gap-[3px]",
          for _ in 0..3 {
            span { class: "block h-0.5 w-4 rounded-full bg-fg" }
          }
        }
        span { class: "hidden sm:inline", "Menu" }
      }
      div { class: "flex min-w-0 items-center gap-2.5",
        span { class: "flex h-7 shrink-0 items-center rounded-md bg-primary px-1.5 text-[11px] font-extrabold tracking-wider text-on-primary", "TMS" }
        match &event {
          Some(e) => rsx! {
            span { class: "truncate text-sm font-semibold", "{e.name}" }
            span { class: "hidden font-mono text-xs text-muted sm:inline", "{e.code}" }
          },
          None => rsx! { span { class: "text-sm text-muted", "No active event" } },
        }
      }
      div { class: "ml-auto flex items-center gap-3",
        if roles.iter().any(|r| r.satisfies(Role::HeadReferee) || r.satisfies(Role::JudgeAdvisor)) {
          IssuesPill {}
        }
        EventClock { timezone: event.as_ref().map(|e| e.timezone.clone()) }
        ConnectionPill {}
      }
    }
  }
}

/// Where this login can go, plus the venue screens, the theme, full screen and logging out.
#[component]
fn Menu(onclose: EventHandler<()>) -> Element {
  let session = use_context::<Session>();
  let mut theme = use_context::<Theme>();
  let mut confirm_log_out = use_signal(|| false);
  let current = use_route::<Route>();
  let state = session.read();
  let roles = state.roles();
  let has = |role| has_role(&roles, role);

  let mut items = Vec::new();
  if Route::primary(&roles) == (Route::Home {}) {
    items.push((Route::Home {}, "Home", current == Route::Home {}));
  }
  if has(Role::Admin) {
    items.push((Route::SetupEvent {}, "Event setup", current.is_setup()));
  }
  if has(Role::HeadReferee) {
    items.push((
      Route::MatchControl {},
      "Match control",
      matches!(current, Route::MatchControl {} | Route::ScoresheetReview {}),
    ));
  }
  if has(Role::Referee) {
    items.push((
      Route::RefereeStation {},
      "Referee station",
      current == Route::RefereeStation {},
    ));
  }
  if has(Role::JudgeAdvisor) {
    items.push((
      Route::JudgingDashboard {},
      "Judging",
      matches!(
        current,
        Route::JudgingDashboard {} | Route::RubricReview {} | Route::JudgingScores {} | Route::JudgingDeliberation {}
      ),
    ));
  }
  if has(Role::Judge) {
    items.push((
      Route::JudgeStation {},
      "Judge station",
      current == Route::JudgeStation {},
    ));
  }
  if has(Role::Queuer) {
    items.push((Route::QueueBoard {}, "Queue board", current == Route::QueueBoard {}));
  }
  if has(Role::Emcee) {
    items.push((Route::Emcee {}, "Emcee", current == Route::Emcee {}));
  }
  if has(Role::HeadReferee) || has(Role::JudgeAdvisor) {
    items.push((Route::Print {}, "Print", current == Route::Print {}));
  }
  items.push((Route::Settings {}, "Settings", current == Route::Settings {}));

  let section = "px-3 pt-4 pb-1 text-xs font-semibold uppercase tracking-wider text-muted";
  rsx! {
    div { class: "fixed inset-0 z-40 bg-black/40", onclick: move |_| onclose.call(()),
      nav {
        class: "tms-slide flex h-full w-76 max-w-[85vw] flex-col gap-0.5 overflow-y-auto border-r border-line bg-surface px-2 shadow-2xl",
        "data-testid": "menu",
        onclick: move |e| e.stop_propagation(),
        div { class: "-mx-2 mb-1 flex items-start justify-between gap-2 border-b border-line px-4 py-4",
          div { class: "min-w-0",
            p { class: "truncate font-semibold", "{state.display_name()}" }
            div { class: "mt-1 flex flex-wrap gap-1",
              for role in roles.iter() {
                Badge { tone: Tone::Primary, "{role.label()}" }
              }
            }
          }
          button { class: "rounded-control px-2 text-2xl leading-none text-muted hover:bg-surface-2 hover:text-fg", "aria-label": "Close menu", onclick: move |_| onclose.call(()), "×" }
        }
        p { class: section, "Screens" }
        for (route , label , active) in items {
          Link {
            to: route,
            class: if active { "rounded-control bg-primary-soft px-3 py-2.5 font-semibold text-primary-strong" } else { "rounded-control px-3 py-2.5 font-medium hover:bg-surface-2" },
            onclick: move |_| onclose.call(()),
            "{label}"
          }
        }
        p { class: section, "Venue screens" }
        for (to , name , _) in venue_screens() {
          Link { to, new_tab: true, class: "rounded-control px-3 py-2 text-sm text-muted hover:bg-surface-2 hover:text-fg", "{name} ↗" }
        }
        div { class: "-mx-2 mt-auto flex flex-col gap-2 border-t border-line p-4",
          div { class: "grid grid-cols-2 gap-2",
            Button {
              variant: ButtonVariant::Secondary,
              size: ButtonSize::Small,
              onclick: move |_| {
                  let next = match theme.mode() {
                      ThemeMode::System => ThemeMode::Light,
                      ThemeMode::Light => ThemeMode::Dark,
                      ThemeMode::Dark => ThemeMode::System,
                  };
                  theme.set(next);
              },
              "Theme: {theme.mode().label()}"
            }
            Button {
              variant: ButtonVariant::Secondary,
              size: ButtonSize::Small,
              onclick: move |_| {
                  document::eval(
                      "document.fullscreenElement ? document.exitFullscreen() : document.documentElement.requestFullscreen()",
                  );
                  onclose.call(());
              },
              "Full screen"
            }
          }
          Button { variant: ButtonVariant::Danger, full_width: true, onclick: move |_| confirm_log_out.set(true), "Log out" }
        }
      }
    }
    if confirm_log_out() {
      LogOutDialog { onclose: move |()| confirm_log_out.set(false) }
    }
  }
}

/// How many errors the schedule checks find, shown to those who can act on them.
#[component]
fn IssuesPill() -> Element {
  use_subscription(Topic::Issues);
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let errors = realtime
    .stores
    .issues
    .read()
    .iter()
    .filter(|i| i.severity == tms_core::validation::IssueSeverity::Error)
    .count();
  if errors == 0 {
    return rsx! {};
  }
  let label = if errors == 1 {
    "1 schedule error".to_owned()
  } else {
    format!("{errors} schedule errors")
  };
  if has_role(&session.read().roles(), Role::Admin) {
    rsx! {
      Link { to: Route::SetupSchedule {}, "data-testid": "issues-pill", Badge { tone: Tone::Danger, "{label}" } }
    }
  } else {
    rsx! { span { "data-testid": "issues-pill", Badge { tone: Tone::Danger, "{label}" } } }
  }
}

#[component]
fn EventClock(timezone: Option<String>) -> Element {
  let realtime = use_context::<Realtime>();
  let mut now = use_signal(|| realtime.server_now_ms());
  use_future(move || async move {
    loop {
      gloo_timers::future::TimeoutFuture::new(250).await;
      now.set(realtime.server_now_ms());
    }
  });
  let tz = timezone.unwrap_or_else(|| "UTC".to_owned());
  let synced = realtime.stores.offset_ms.read().is_some();
  rsx! {
    span {
      class: "font-mono text-sm tabular-nums",
      title: if synced { "Server time, {tz}" } else { "Local time, not yet synced with the server" },
      "{format_clock(now(), &tz)}"
    }
  }
}

#[component]
fn ConnectionPill() -> Element {
  let realtime = use_context::<Realtime>();
  let (tone, text) = match *realtime.stores.status.read() {
    ConnStatus::Online => (Tone::Success, "Online"),
    ConnStatus::Connecting => (Tone::Warning, "Connecting"),
    ConnStatus::Offline => (Tone::Danger, "Offline"),
  };
  rsx! { Badge { tone, "{text}" } }
}

#[component]
fn LogOutDialog(onclose: EventHandler<()>) -> Element {
  let realtime = use_context::<Realtime>();
  let mut session = use_context::<Session>();
  let mut busy = use_signal(|| false);
  let is_key = matches!(
    session.read(),
    SessionState::OfflineKey { .. } | SessionState::Online { key: Some(_), .. }
  );

  rsx! {
    Modal {
      title: "Log out of this device?",
      onclose,
      footer: rsx! {
        Button { variant: ButtonVariant::Secondary, onclick: move |_| onclose.call(()), "Cancel" }
        Button {
          variant: ButtonVariant::Danger,
          loading: busy(),
          onclick: move |_| async move {
              busy.set(true);
              let token = session.peek().token().map(str::to_owned);
              if let Some(token) = token {
                  // Best effort: an unreachable server just lets the session expire on its own.
                  let _ = api::post_empty("/auth/logout", Some(&token), &()).await;
              }
              session.set(SessionState::LoggedOut);
              realtime.reconnect();
              navigator().replace(Route::Login { access: String::new() });
          },
          "Log out"
        }
      },
      if is_key {
        p { "This device is logged in with an access key. You will need the key to log in again." }
      } else {
        p { "You will need your password to log in again." }
      }
    }
  }
}

/// Shows exactly one banner, by priority: connection, session trust, then event announcements.
#[component]
fn BannerSlot() -> Element {
  let realtime = use_context::<Realtime>();
  let session = use_context::<Session>();
  let status = *realtime.stores.status.read();
  let ever_connected = realtime.stores.last_connected_ms.read().is_some();

  let unverified_key = matches!(session.read(), SessionState::OfflineKey { rejected: false, .. });

  if status == ConnStatus::Offline {
    let connection = if ever_connected {
      "Offline. Showing the last data received; actions that need the server are unavailable. Reconnecting…"
    } else {
      "Cannot reach the server. Retrying…"
    };
    // The key warning would otherwise be hidden behind the connection banner exactly when it matters.
    let message = if unverified_key {
      format!("{connection} Unverified offline session: the access key is checked when the server is reachable.")
    } else {
      connection.to_owned()
    };
    return rsx! { Banner { tone: Tone::Danger, message } };
  }
  match session.read() {
    SessionState::OfflineKey { rejected: true, .. } => {
      return rsx! {
        Banner { tone: Tone::Danger, message: "The server rejected this device's access key. Ask the event admin for a new key." }
      };
    }
    SessionState::OfflineKey { .. } => {
      return rsx! {
        Banner { tone: Tone::Warning, message: "Unverified offline session. The key will be checked when the server is reachable." }
      };
    }
    _ => {}
  }

  let banners = realtime.stores.banners.read();
  let Some(top) = banners.iter().max_by_key(|b| (severity_rank(b.severity), b.created_at)) else {
    return rsx! {};
  };
  let more = banners.len() - 1;
  let message = if more > 0 {
    format!("{} (+{more} more)", top.message)
  } else {
    top.message.clone()
  };
  rsx! { Banner { tone: severity_tone(top.severity), message } }
}

fn severity_rank(s: BannerSeverity) -> u8 {
  match s {
    BannerSeverity::Success => 0,
    BannerSeverity::Info => 1,
    BannerSeverity::Warning => 2,
    BannerSeverity::Error => 3,
  }
}

fn severity_tone(s: BannerSeverity) -> Tone {
  match s {
    BannerSeverity::Success => Tone::Success,
    BannerSeverity::Info => Tone::Info,
    BannerSeverity::Warning => Tone::Warning,
    BannerSeverity::Error => Tone::Danger,
  }
}
