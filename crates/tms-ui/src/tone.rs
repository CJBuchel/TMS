use dioxus::prelude::*;

/// Meaning carried by colour. Every status enum in TMS maps each variant to one of these.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum Tone {
  #[default]
  Neutral,
  Primary,
  Info,
  Success,
  Warning,
  Danger,
}

impl Tone {
  /// Soft background with strong text and border, for banners and notes.
  pub fn soft_classes(self) -> &'static str {
    match self {
      Tone::Neutral => "bg-surface-2 text-fg border-line",
      Tone::Primary => "bg-primary-soft text-primary-strong border-primary",
      Tone::Info => "bg-info-soft text-info-strong border-info",
      Tone::Success => "bg-success-soft text-success-strong border-success",
      Tone::Warning => "bg-warning-soft text-warning-strong border-warning",
      Tone::Danger => "bg-danger-soft text-danger-strong border-danger",
    }
  }

  /// The solid colour, for dots and stripes.
  pub fn dot_class(self) -> &'static str {
    match self {
      Tone::Neutral => "bg-line-strong",
      Tone::Primary => "bg-primary",
      Tone::Info => "bg-info",
      Tone::Success => "bg-success",
      Tone::Warning => "bg-warning",
      Tone::Danger => "bg-danger",
    }
  }

  fn pill_classes(self) -> &'static str {
    match self {
      Tone::Neutral => "bg-surface-2 text-muted",
      Tone::Primary => "bg-primary-soft text-primary-strong",
      Tone::Info => "bg-info-soft text-info-strong",
      Tone::Success => "bg-success-soft text-success-strong",
      Tone::Warning => "bg-warning-soft text-warning-strong",
      Tone::Danger => "bg-danger-soft text-danger-strong",
    }
  }
}

/// A small status pill with a coloured dot.
#[component]
pub fn Badge(#[props(default)] tone: Tone, children: Element) -> Element {
  rsx! {
    span {
      class: "inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-semibold whitespace-nowrap {tone.pill_classes()}",
      span { class: "h-1.5 w-1.5 shrink-0 rounded-full {tone.dot_class()}" }
      {children}
    }
  }
}
