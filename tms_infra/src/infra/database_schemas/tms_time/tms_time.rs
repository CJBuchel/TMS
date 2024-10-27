use chrono::Timelike;
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::DataSchemeExtensions;

use super::{TmsDuration, TmsTimeBased};

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct TmsTime {
  pub hour: u32,   // 24-hour format
  pub minute: u32, // 0-59
  pub second: u32, // 0-59
}

impl TmsTime {
  #[flutter_rust_bridge::frb(sync)]
  pub fn new(hour: u32, minute: u32, second: u32) -> Self {
    Self { hour, minute, second }
  }
}

impl TmsTimeBased for TmsTime {
  fn now() -> Self {
    // get current date time (no timezone)
    let now = chrono::Local::now();
    Self {
      hour: now.hour(),
      minute: now.minute(),
      second: now.second(),
    }
  }

  #[flutter_rust_bridge::frb(sync)]
  fn compare_to(&self, other: Self) -> i32 {
    if self.hour < other.hour {
      return -1;
    } else if self.hour > other.hour {
      return 1;
    }

    if self.minute < other.minute {
      return -1;
    } else if self.minute > other.minute {
      return 1;
    }

    if self.second < other.second {
      return -1;
    } else if self.second > other.second {
      return 1;
    }

    return 0;
  }

  #[flutter_rust_bridge::frb(sync)]
  fn duration(&self) -> TmsDuration {
    let hours = self.hour as i32;
    let minutes = self.minute as i32;
    let seconds = self.second as i32;

    TmsDuration::new(None, None, None, Some(hours), Some(minutes), Some(seconds))
  }

  #[flutter_rust_bridge::frb(sync)]
  fn difference(&self, other: Self) -> TmsDuration {
    self.duration().difference(other.duration())
  }

  #[flutter_rust_bridge::frb(sync)]
  fn is_after(&self, other: Self) -> bool {
    self.compare_to(other) == 1
  }

  #[flutter_rust_bridge::frb(sync)]
  fn is_before(&self, other: Self) -> bool {
    self.compare_to(other) == -1
  }

  #[flutter_rust_bridge::frb(sync)]
  fn is_same_moment(&self, other: Self) -> bool {
    self.compare_to(other) == 0
  }
  
  #[flutter_rust_bridge::frb(sync)]
  fn to_string(&self) -> String {
    format!("{:02}:{:02}:{:02}", self.hour, self.minute, self.second)
  }

  #[flutter_rust_bridge::frb(sync)]
  fn add_duration(&self, duration: TmsDuration) -> Self {
    let added_duration = self.duration().add(duration);
    Self {
      hour: added_duration.hours.unwrap_or(self.hour as i32) as u32,
      minute: added_duration.minutes.unwrap_or(self.minute as i32) as u32,
      second: added_duration.seconds.unwrap_or(self.second as i32) as u32,
    }
  }
}

impl Default for TmsTime {
  fn default() -> Self {
    Self {
      hour: 0,
      minute: 0,
      second: 0,
    }
  }
}

impl DataSchemeExtensions for TmsTime {}