use dioxus::prelude::*;

use crate::Tone;

/// Full-width strip under the top bar. Only one is shown at a time, chosen by priority in the app shell.
#[component]
pub fn Banner(
  tone: Tone,
  message: String,
  #[props(default)] action: Option<Element>,
  #[props(default)] ondismiss: Option<EventHandler<()>>,
) -> Element {
  let role = if matches!(tone, Tone::Danger | Tone::Warning) {
    "alert"
  } else {
    "status"
  };
  rsx! {
    div { role, class: "flex items-center gap-3 border-b px-4 py-2 text-sm font-medium {tone.soft_classes()}",
      span { class: "h-2 w-2 shrink-0 rounded-full {tone.dot_class()}" }
      span { class: "flex-1", "{message}" }
      if let Some(action) = action {
        {action}
      }
      if let Some(ondismiss) = ondismiss {
        button {
          class: "rounded-md px-2 text-lg leading-none opacity-70 hover:opacity-100",
          title: "Dismiss",
          onclick: move |_| ondismiss.call(()),
          "×"
        }
      }
    }
  }
}
