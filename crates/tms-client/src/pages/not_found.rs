use dioxus::prelude::*;
use tms_ui::Card;

use crate::routes::Route;

#[component]
pub fn NotFound(segments: Vec<String>) -> Element {
  let path = segments.join("/");
  rsx! {
    div { class: "mx-auto max-w-md p-6",
      Card { title: "Page not found",
        p { class: "mb-3 text-sm", "Nothing lives at /{path}." }
        Link { to: Route::Home {}, class: "text-sm font-semibold text-primary underline", "Go to home" }
      }
    }
  }
}
