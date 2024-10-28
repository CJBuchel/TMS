use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::infra::DataSchemeExtensions;

use super::{TmsDate, TmsDuration, TmsTime, TmsTimeBased};

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct TmsDateTime {
  pub date: Option<TmsDate>,
  pub time: Option<TmsTime>,
}

impl TmsDateTime {
  #[flutter_rust_bridge::frb(sync)]
  pub fn new(date: Option<TmsDate>, time: Option<TmsTime>) -> Self {
    Self { date, time }
  }
}

impl TmsTimeBased for TmsDateTime {
  fn now() -> Self {
    Self {
      date: Some(TmsDate::now()),
      time: Some(TmsTime::now()),
    }
  }

  #[flutter_rust_bridge::frb(sync)]
  fn compare_to(&self, other: Self) -> i32 {
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
  fn duration(&self) -> TmsDuration {
    let date_duration = match &self.date {
      Some(date) => date.duration(),
      None => TmsDuration::new(None, None, None, None, None, None),
    };

    let time_duration = match &self.time {
      Some(time) => time.duration(),
      None => TmsDuration::new(None, None, None, None, None, None),
    };

    TmsDuration::new(
      date_duration.years,
      date_duration.months,
      date_duration.days,
      time_duration.hours,
      time_duration.minutes,
      time_duration.seconds,
    )
  }

  #[flutter_rust_bridge::frb(sync)]
  fn difference(&self, other: Self) -> TmsDuration {
    self.duration().difference(other.duration())
  }

  #[flutter_rust_bridge::frb(sync)]
  fn is_after(&self, other: Self) -> bool {
    self.compare_to(other) > 0
  }

  #[flutter_rust_bridge::frb(sync)]
  fn is_before(&self, other: Self) -> bool {
    self.compare_to(other) < 0
  }

  #[flutter_rust_bridge::frb(sync)]
  fn is_same_moment(&self, other: Self) -> bool {
    self.compare_to(other) == 0
  }

  #[flutter_rust_bridge::frb(sync)]
  fn to_string(&self) -> String {
    let date_str = match &self.date {
      Some(date) => date.to_string(),
      None => "".to_string(),
    };

    let time_str = match &self.time {
      Some(time) => time.to_string(),
      None => "".to_string(),
    };

    format!("{} {}", date_str, time_str)
  }

  #[flutter_rust_bridge::frb(sync)]
  fn add_duration(&self, duration: TmsDuration) -> Self {
    let date: Option<TmsDate> = match &self.date {
      Some(date) => Some(date.add_duration(duration.clone())),
      None => None,
    };

    let time: Option<TmsTime> = match &self.time {
      Some(time) => Some(time.add_duration(duration.clone())),
      None => None,
    };

    Self { date, time }
  }
}

impl Default for TmsDateTime {
  fn default() -> Self {
    Self { date: None, time: None }
  }
}

impl DataSchemeExtensions for TmsDateTime {}
