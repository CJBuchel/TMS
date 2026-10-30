use dioxus::prelude::*;

/// A row of tabs on a tinted track; the chosen one is raised.
#[component]
pub fn Tabs(children: Element) -> Element {
  rsx! {
    div { role: "tablist", class: "inline-flex max-w-full flex-wrap gap-1 rounded-panel bg-surface-2 p-1 ring-1 ring-line ring-inset",
      {children}
    }
  }
}

#[component]
pub fn Tab(active: bool, onclick: EventHandler<MouseEvent>, children: Element) -> Element {
  rsx! {
    button {
      r#type: "button",
      role: "tab",
      "aria-selected": "{active}",
      class: if active { "rounded-control bg-surface px-4 py-2 text-sm font-semibold shadow-sm" } else { "rounded-control px-4 py-2 text-sm font-medium text-muted hover:bg-surface/60 hover:text-fg" },
      onclick: move |e| onclick.call(e),
      {children}
    }
  }
}
