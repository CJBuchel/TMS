use dioxus::prelude::*;

/// Rounded panel with an optional header: a title, and actions on the right.
#[component]
pub fn Card(
  #[props(default)] title: Option<String>,
  #[props(default)] actions: Option<Element>,
  #[props(default)] class: String,
  children: Element,
) -> Element {
  rsx! {
    section { class: "rounded-panel border border-line bg-surface shadow-panel {class}",
      if title.is_some() || actions.is_some() {
        header { class: "flex flex-wrap items-center justify-between gap-2 px-4 pt-3.5 pb-1",
          if let Some(title) = title {
            h2 { class: "text-base font-semibold tracking-tight", "{title}" }
          }
          if let Some(actions) = actions {
            div { class: "flex items-center gap-2", {actions} }
          }
        }
      }
      div { class: "p-4", {children} }
    }
  }
}

/// A label and value row for detail panels.
#[component]
pub fn KeyValue(label: String, children: Element) -> Element {
  rsx! {
    div { class: "flex items-baseline justify-between gap-4 border-b border-line py-2 last:border-b-0",
      dt { class: "text-sm text-muted", "{label}" }
      dd { class: "text-sm font-medium text-right tabular-nums break-all", {children} }
    }
  }
}
