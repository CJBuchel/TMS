use chrono::{Datelike, Timelike};
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::infra::DataSchemeExtensions;

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct TmsDate {
  pub year: i32,  // 4-digit year
  pub month: u32, // 1-12
  pub day: u32,   // 1-31
}

impl TmsDate {
  pub fn now() -> Self {
    // get current date time (no timezone)
    let now = chrono::Local::now();
    Self {
      year: now.year(),
      month: now.month(),
      day: now.day(),
    }
  }

  pub fn new(year: i32, month: u32, day: u32) -> Self {
    Self { year, month, day }
  }
}

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct TmsTime {
  pub hour: u32,   // 24-hour format
  pub minute: u32, // 0-59
  pub second: u32, // 0-59
}

impl TmsTime {
  pub fn now() -> Self {
    // get current date time (no timezone)
    let now = chrono::Local::now();
    Self {
      hour: now.hour(),
      minute: now.minute(),
      second: now.second(),
    }
  }

  pub fn new(hour: u32, minute: u32, second: u32) -> Self {
    Self { hour, minute, second }
  }
}

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct TmsDateTime {
  pub date: Option<TmsDate>,
  pub time: Option<TmsTime>,
}

impl TmsDateTime {
  pub fn now() -> Self {
    Self {
      date: Some(TmsDate::now()),
      time: Some(TmsTime::now()),
    }
  }

  pub fn new(date: Option<TmsDate>, time: Option<TmsTime>) -> Self {
    Self { date, time }
  }
}

impl Default for TmsDateTime {
  fn default() -> Self {
    Self { date: None, time: None }
  }
}

impl DataSchemeExtensions for TmsDateTime {}
