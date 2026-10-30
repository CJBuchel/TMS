use dioxus::prelude::*;
use gloo_storage::{LocalStorage, Storage};
use serde::{Deserialize, Serialize};

const STORAGE_KEY: &str = "tms.theme";

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, Default)]
pub enum ThemeMode {
  #[default]
  System,
  Light,
  Dark,
}

impl ThemeMode {
  pub const ALL: [ThemeMode; 3] = [ThemeMode::System, ThemeMode::Light, ThemeMode::Dark];

  pub fn label(self) -> &'static str {
    match self {
      ThemeMode::System => "System",
      ThemeMode::Light => "Light",
      ThemeMode::Dark => "Dark",
    }
  }

  pub fn key(self) -> &'static str {
    match self {
      ThemeMode::System => "system",
      ThemeMode::Light => "light",
      ThemeMode::Dark => "dark",
    }
  }

  pub fn from_key(key: &str) -> Self {
    ThemeMode::ALL.into_iter().find(|m| m.key() == key).unwrap_or_default()
  }

  /// `system` removes the attribute so the stylesheet's `prefers-color-scheme` rule applies.
  fn apply(self) {
    let Some(root) = web_sys::window()
      .and_then(|w| w.document())
      .and_then(|d| d.document_element())
    else {
      return;
    };
    let _ = match self {
      ThemeMode::System => root.remove_attribute("data-theme"),
      mode => root.set_attribute("data-theme", mode.key()),
    };
  }
}

#[derive(Clone, Copy)]
pub struct Theme(Signal<ThemeMode>);

impl Theme {
  pub fn load() -> Self {
    let mode: ThemeMode = LocalStorage::get(STORAGE_KEY).unwrap_or_default();
    mode.apply();
    Self(Signal::new(mode))
  }

  pub fn mode(&self) -> ThemeMode {
    *self.0.read()
  }

  pub fn set(&mut self, mode: ThemeMode) {
    let _ = LocalStorage::set(STORAGE_KEY, mode);
    mode.apply();
    self.0.set(mode);
  }
}
