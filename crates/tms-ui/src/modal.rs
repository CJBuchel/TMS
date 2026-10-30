use dioxus::prelude::*;

/// Centred dialog over a dimmed page. The caller owns the open state and renders this only while open.
#[component]
pub fn Modal(title: String, onclose: EventHandler<()>, footer: Element, children: Element) -> Element {
  rsx! {
    div {
      class: "fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 backdrop-blur-[2px]",
      onclick: move |_| onclose.call(()),
      div {
        role: "dialog",
        aria_modal: "true",
        class: "tms-pop w-full max-w-md overflow-hidden rounded-panel border border-line bg-surface shadow-2xl",
        onclick: move |e| e.stop_propagation(),
        header { class: "px-5 pt-5 pb-1 text-lg font-semibold tracking-tight", "{title}" }
        div { class: "px-5 py-3 text-sm", {children} }
        footer { class: "flex justify-end gap-2 bg-surface-2 px-5 py-3", {footer} }
      }
    }
  }
}
