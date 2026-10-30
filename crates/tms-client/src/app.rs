use dioxus::prelude::*;

use crate::net::realtime::use_realtime_provider;
use crate::routes::Route;
use crate::store::outbox::{OutboxState, use_outbox_provider};
use crate::store::session::{Session, use_token_refresh};
use crate::store::theme::Theme;

#[component]
pub fn App() -> Element {
  let session = use_context_provider(Session::load);
  use_context_provider(Theme::load);
  let realtime = use_realtime_provider(session);
  let outbox = use_outbox_provider(session, realtime);
  use_effect(move || {
    let waiting = outbox
      .items()
      .iter()
      .filter(|i| !matches!(i.state, OutboxState::Sent { .. }))
      .count();
    realtime.report_waiting(u32::try_from(waiting).unwrap_or(u32::MAX));
  });
  use_token_refresh(session);

  // Inter ships with TMS so every device shows the same type. The asset path is hashed, so the face is declared here.
  let inter = asset!("/assets/fonts/InterVariable.woff2");
  let font_face = format!(
    "@font-face {{ font-family: 'Inter'; font-style: normal; font-weight: 100 900; font-display: swap; src: url('{inter}') format('woff2'); }}"
  );

  rsx! {
    document::Style { {font_face} }
    document::Stylesheet { href: asset!("/assets/tailwind.css") }
    document::Title { "TMS" }
    document::Meta { name: "viewport", content: "width=device-width, initial-scale=1, viewport-fit=cover" }
    Router::<Route> {}
  }
}
