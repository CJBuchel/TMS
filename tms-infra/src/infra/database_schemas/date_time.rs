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

  // returns a -1 if self is less than other, 0 if equal, and a +1 if self is greater than other
  #[flutter_rust_bridge::frb(sync)]
  pub fn compare_to(&self, other: TmsDate) -> i32 {
    if self.year < other.year {
      return -1;
    } else if self.year > other.year {
      return 1;
    }

    if self.month < other.month {
      return -1;
    } else if self.month > other.month {
      return 1;
    }

    if self.day < other.day {
      return -1;
    } else if self.day > other.day {
      return 1;
    }

    return 0;
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

  // returns a -1 if self is less than other, 0 if equal, and a +1 if self is greater than other
  #[flutter_rust_bridge::frb(sync)]
  pub fn compare_to(&self, other: TmsTime) -> i32 {
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

  // returns a -1 if self is less than other, 0 if equal, and a +1 if self is greater than other
  #[flutter_rust_bridge::frb(sync)]
  pub fn compare_to(&self, other: TmsDateTime) -> i32 {
    if let Some(date) = &self.date {
      if let Some(other_date) = &other.date {
        let date_compare = date.compare_to(other_date.clone());
        if date_compare != 0 {
          return date_compare;
        }
      }
    }

    if let Some(time) = &self.time {
      if let Some(other_time) = &other.time {
        return time.compare_to(other_time.clone());
      }
    }

    return 0;
  }
}

impl Default for TmsDateTime {
  fn default() -> Self {
    Self { date: None, time: None }
  }
}

impl DataSchemeExtensions for TmsDateTime {}
