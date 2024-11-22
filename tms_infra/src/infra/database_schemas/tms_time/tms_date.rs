use chrono::Datelike;
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::DataSchemeExtensions;

use super::{TmsDuration, TmsTimeBased};

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct TmsDate {
  pub year: i32,  // 4-digit year
  pub month: u32, // 1-12
  pub day: u32,   // 1-31
}

impl TmsDate {
  
  pub fn new(year: i32, month: u32, day: u32) -> Self {
    Self { year, month, day }
  }
}

impl TmsTimeBased for TmsDate {
  fn now() -> Self {
    // get current date time (no timezone)
    let now = chrono::Local::now();
    Self {
      year: now.year(),
      month: now.month(),
      day: now.day(),
    }
  }

  // returns a -1 if self is less than other, 0 if equal, and a +1 if self is greater than other
  
  fn compare_to(&self, other: TmsDate) -> i32 {
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

  
  fn duration(&self) -> TmsDuration {
    let years = self.year as i32;
    let months = self.month as i32;
    let days = self.day as i32;

    TmsDuration::new(Some(years), Some(months), Some(days), None, None, None)
  }

  
  fn difference(&self, other: TmsDate) -> TmsDuration {
    self.duration().difference(other.duration())
  }

  
  fn is_after(&self, other: Self) -> bool {
    self.compare_to(other) == 1
  }

  
  fn is_before(&self, other: Self) -> bool {
    self.compare_to(other) == -1
  }

  
  fn is_same_moment(&self, other: Self) -> bool {
    self.compare_to(other) == 0
  }

  
  fn to_string(&self) -> String {
    format!("{:04}-{:02}-{:02}", self.year, self.month, self.day)
  }

  
  fn add_duration(&self, duration: TmsDuration) -> Self {
    let added_duration = self.duration().add(duration);
    Self {
      year: (self.year + added_duration.years.unwrap_or(self.year)) as i32,
      month: (self.month as i32 + added_duration.months.unwrap_or(self.month as i32)) as u32,
      day: (self.day as i32 + added_duration.days.unwrap_or(self.day as i32)) as u32,
    }
  }
}

impl Default for TmsDate {
  fn default() -> Self {
    Self {
      year: 0,
      month: 0,
      day: 0,
    }
  }
}

impl DataSchemeExtensions for TmsDate {}