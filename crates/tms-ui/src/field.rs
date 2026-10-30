use dioxus::prelude::*;

const CONTROL: &str = "h-11 rounded-control border bg-surface px-3 text-base text-fg shadow-sm outline-none transition placeholder:text-muted focus:border-focus focus:ring-4 focus:ring-focus/20 disabled:opacity-60";

#[component]
pub fn TextField(
  label: String,
  value: String,
  oninput: EventHandler<String>,
  #[props(default = "text".to_string())] r#type: String,
  #[props(default)] placeholder: String,
  #[props(default)] autocomplete: String,
  #[props(default)] error: Option<String>,
  #[props(default)] hint: Option<String>,
  #[props(default)] disabled: bool,
  #[props(default)] autofocus: bool,
  #[props(default)] mono: bool,
) -> Element {
  let border = if error.is_some() {
    "border-danger"
  } else {
    "border-line-strong"
  };
  let font = if mono { "font-mono tracking-wider" } else { "" };
  rsx! {
    label { class: "flex flex-col gap-1.5",
      span { class: "text-sm font-medium", "{label}" }
      input {
        r#type,
        value,
        placeholder,
        autocomplete,
        disabled,
        autofocus,
        class: "{CONTROL} {border} {font}",
        oninput: move |e| oninput.call(e.value()),
      }
      if let Some(error) = error {
        span { class: "text-sm text-danger-strong", "{error}" }
      } else if let Some(hint) = hint {
        span { class: "text-sm text-muted", "{hint}" }
      }
    }
  }
}

/// Native select: accessible, works well on iPad, and needs no custom popover.
#[component]
pub fn Select(
  label: String,
  value: String,
  options: Vec<(String, String)>,
  onchange: EventHandler<String>,
  #[props(default)] disabled: bool,
) -> Element {
  rsx! {
    label { class: "flex flex-col gap-1.5",
      span { class: "text-sm font-medium", "{label}" }
      select {
        disabled,
        class: "{CONTROL} border-line-strong px-2",
        onchange: move |e| onchange.call(e.value()),
        for (key , text) in options {
          option { value: "{key}", selected: key == value, "{text}" }
        }
      }
    }
  }
}

/// A labelled checkbox with a large hit area.
#[component]
pub fn Checkbox(
  label: String,
  checked: bool,
  onchange: EventHandler<bool>,
  #[props(default)] disabled: bool,
) -> Element {
  rsx! {
    label { class: "flex cursor-pointer items-center gap-2 py-1 text-sm select-none",
      input {
        r#type: "checkbox",
        checked,
        disabled,
        class: "h-4 w-4 rounded accent-primary",
        onchange: move |e| onchange.call(e.checked()),
      }
      span { "{label}" }
    }
  }
}
