use dioxus::prelude::*;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum ButtonVariant {
  #[default]
  Primary,
  Secondary,
  Ghost,
  Danger,
  /// Destructive but secondary, such as cancelling one match in a long list: quiet until hovered, then red.
  DangerGhost,
  Warning,
  Success,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum ButtonSize {
  Small,
  #[default]
  Medium,
  /// Station screens on iPads: 48 px tall for gloved or hurried taps.
  Large,
  /// The one action a station screen is for.
  Huge,
}

impl ButtonVariant {
  fn classes(self) -> &'static str {
    match self {
      ButtonVariant::Primary => "bg-primary text-on-primary border-primary shadow-sm hover:bg-primary-strong",
      ButtonVariant::Secondary => "bg-surface text-fg border-line-strong shadow-sm hover:bg-surface-2",
      ButtonVariant::Ghost => "bg-transparent text-fg border-transparent hover:bg-surface-2",
      ButtonVariant::Danger => "bg-danger text-on-primary border-danger shadow-sm hover:bg-danger-strong",
      ButtonVariant::DangerGhost => {
        "bg-transparent text-muted border-transparent hover:bg-danger-soft hover:text-danger-strong"
      }
      ButtonVariant::Warning => "bg-warning text-on-warning border-warning shadow-sm hover:brightness-95",
      ButtonVariant::Success => "bg-success text-on-primary border-success shadow-sm hover:bg-success-strong",
    }
  }
}

impl ButtonSize {
  fn classes(self) -> &'static str {
    match self {
      ButtonSize::Small => "h-8 px-3 text-xs rounded-control",
      ButtonSize::Medium => "h-10 px-4 text-sm rounded-control",
      ButtonSize::Large => "h-12 px-5 text-base rounded-panel",
      ButtonSize::Huge => "h-16 px-6 text-lg rounded-panel",
    }
  }
}

#[component]
pub fn Button(
  #[props(default)] variant: ButtonVariant,
  #[props(default)] size: ButtonSize,
  #[props(default)] disabled: bool,
  #[props(default)] loading: bool,
  #[props(default)] full_width: bool,
  #[props(default = "button".to_string())] r#type: String,
  #[props(default)] title: String,
  onclick: Option<EventHandler<MouseEvent>>,
  children: Element,
) -> Element {
  let width = if full_width { "w-full" } else { "" };
  rsx! {
    button {
      r#type,
      title,
      disabled: disabled || loading,
      class: "inline-flex items-center justify-center gap-2 border font-semibold select-none transition active:scale-[0.98] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-focus disabled:opacity-45 disabled:shadow-none disabled:cursor-not-allowed disabled:active:scale-100 {variant.classes()} {size.classes()} {width}",
      onclick: move |e| {
          if let Some(handler) = onclick {
              handler.call(e);
          }
      },
      if loading {
        span { class: "inline-block h-3 w-3 animate-spin rounded-full border-2 border-current border-t-transparent" }
      }
      {children}
    }
  }
}
