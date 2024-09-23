use chrono::{Datelike, Timelike};
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::infra::DataSchemeExtensions;

pub struct TmsDuration {
  pub years: i64,
  pub months: i64,
  pub days: i64,
  pub hours: i64,
  pub minutes: i64,
  pub seconds: i64,
}

impl TmsDuration {
  pub fn new(years: i64, months: i64, days: i64, hours: i64, minutes: i64, seconds: i64) -> Self {
    let mut duration = Self {
      years,
      months,
      days,
      hours,
      minutes,
      seconds,
    };
    duration.normalize();
    duration
  }

  fn normalize(&mut self) {
    if self.seconds >= 60 {
      self.minutes += self.seconds / 60;
      self.seconds %= 60;
    }
    if self.minutes >= 60 {
      self.hours += self.minutes / 60;
      self.minutes %= 60;
    }
    if self.hours >= 24 {
      self.days += self.hours / 24;
      self.hours %= 24;
    }
    if self.days >= 30 {
      self.months += self.days / 30;
      self.days %= 30;
    }
    if self.months >= 12 {
      self.years += self.months / 12;
      self.months %= 12;
    }
  }

  // in years
  pub fn in_years(&self) -> i64 {
    self.years
  }

  // in months
  pub fn in_months(&self) -> i64 {
    self.in_years() * 12 + self.months
  }

  // in days
  pub fn in_days(&self) -> i64 {
    self.in_months() * 30 + self.days
  }

  // in hours
  pub fn in_hours(&self) -> i64 {
    self.in_days() * 24 + self.hours
  }

  // in minutes
  pub fn in_minutes(&self) -> i64 {
    self.in_hours() * 60 + self.minutes
  }

  // in seconds
  pub fn in_seconds(&self) -> i64 {
    self.in_minutes() * 60 + self.seconds
  }


  // difference
  pub fn difference(&self, other: TmsDuration) -> TmsDuration {
    let years = self.years - other.years;
    let months = self.months - other.months;
    let days = self.days - other.days;
    let hours = self.hours - other.hours;
    let minutes = self.minutes - other.minutes;
    let seconds = self.seconds - other.seconds;

    TmsDuration::new(years, months, days, hours, minutes, seconds)
  }
}

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

  #[flutter_rust_bridge::frb(sync)]
  pub fn difference(&self, other: TmsDate) -> TmsDuration {
    let years = self.year as i64 - other.year as i64;
    let months = self.month as i64 - other.month as i64;
    let days = self.day as i64 - other.day as i64;
    let hours = 0;
    let minutes = 0;
    let seconds = 0;

    TmsDuration::new(years, months, days, hours, minutes, seconds)
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

  #[flutter_rust_bridge::frb(sync)]
  pub fn difference(&self, other: TmsTime) -> TmsDuration {
    let years = 0;
    let months = 0;
    let days = 0;
    let hours = self.hour as i64 - other.hour as i64;
    let minutes = self.minute as i64 - other.minute as i64;
    let seconds = self.second as i64 - other.second as i64;

    TmsDuration::new(years, months, days, hours, minutes, seconds)
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

  #[flutter_rust_bridge::frb(sync)]
  pub fn difference(&self, other: TmsDateTime) -> TmsDuration {
    let date_diff = match (&self.date, &other.date) {
      (Some(date), Some(other_date)) => date.difference(other_date.clone()),
      _ => TmsDuration::new(0, 0, 0, 0, 0, 0),
    };

    let time_diff = match (&self.time, &other.time) {
      (Some(time), Some(other_time)) => time.difference(other_time.clone()),
      _ => TmsDuration::new(0, 0, 0, 0, 0, 0),
    };

    TmsDuration::new(
      date_diff.years,
      date_diff.months,
      date_diff.days,
      time_diff.hours,
      time_diff.minutes,
      time_diff.seconds,
    )
  }
}

impl Default for TmsDateTime {
  fn default() -> Self {
    Self { date: None, time: None }
  }
}

impl DataSchemeExtensions for TmsDateTime {}
