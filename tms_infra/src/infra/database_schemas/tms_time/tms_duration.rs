#[derive(Clone, Debug)]
pub struct TmsDuration {
  pub years: Option<i32>,
  pub months: Option<i32>,
  pub days: Option<i32>,
  pub hours: Option<i32>,
  pub minutes: Option<i32>,
  pub seconds: Option<i32>,
}

impl TmsDuration {
  #[flutter_rust_bridge::frb(sync)]
  pub fn new(years: Option<i32>, months: Option<i32>, days: Option<i32>, hours: Option<i32>, minutes: Option<i32>, seconds: Option<i32>) -> Self {
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

  #[flutter_rust_bridge::frb(sync)]
  fn normalize(&mut self) {
    if let Some(seconds) = self.seconds {
      if seconds >= 60 {
        self.minutes = Some(self.minutes.unwrap_or(0).saturating_add(seconds / 60));
        self.seconds = Some(seconds % 60);
      }
    }
    if let Some(minutes) = self.minutes {
      if minutes >= 60 {
        self.hours = Some(self.hours.unwrap_or(0).saturating_add(minutes / 60));
        self.minutes = Some(minutes % 60);
      }
    }
    if let Some(hours) = self.hours {
      if hours >= 24 {
        self.days = Some(self.days.unwrap_or(0).saturating_add(hours / 24));
        self.hours = Some(hours % 24);
      }
    }
    if let Some(days) = self.days {
      if days >= 30 {
        self.months = Some(self.months.unwrap_or(0).saturating_add(days / 30));
        self.days = Some(days % 30);
      }
    }
    if let Some(months) = self.months {
      if months >= 12 {
        self.years = Some(self.years.unwrap_or(0).saturating_add(months / 12));
        self.months = Some(months % 12);
      }
    }
  }

  #[flutter_rust_bridge::frb(sync)]
  pub fn in_years(&self) -> i32 {
    self.years.unwrap_or(0)
  }

  #[flutter_rust_bridge::frb(sync)]
  pub fn in_months(&self) -> i32 {
    self.in_years().saturating_mul(12).saturating_add(self.months.unwrap_or(0))
  }

  #[flutter_rust_bridge::frb(sync)]
  pub fn in_days(&self) -> i32 {
    self.in_months().saturating_mul(30).saturating_add(self.days.unwrap_or(0))
  }

  #[flutter_rust_bridge::frb(sync)]
  pub fn in_hours(&self) -> i32 {
    self.in_days().saturating_mul(24).saturating_add(self.hours.unwrap_or(0))
  }

  #[flutter_rust_bridge::frb(sync)]
  pub fn in_minutes(&self) -> i32 {
    self.in_hours().saturating_mul(60).saturating_add(self.minutes.unwrap_or(0))
  }

  #[flutter_rust_bridge::frb(sync)]
  pub fn in_seconds(&self) -> i32 {
    self.in_minutes().saturating_mul(60).saturating_add(self.seconds.unwrap_or(0))
  }

  #[flutter_rust_bridge::frb(sync)]
  pub fn difference(&self, other: TmsDuration) -> TmsDuration {
    let years = match (self.years, other.years) {
      (Some(self_years), Some(other_years)) => Some(self_years.saturating_sub(other_years)),
      _ => None,
    };
    let months = match (self.months, other.months) {
      (Some(self_months), Some(other_months)) => Some(self_months.saturating_sub(other_months)),
      _ => None,
    };
    let days = match (self.days, other.days) {
      (Some(self_days), Some(other_days)) => Some(self_days.saturating_sub(other_days)),
      _ => None,
    };
    let hours = match (self.hours, other.hours) {
      (Some(self_hours), Some(other_hours)) => Some(self_hours.saturating_sub(other_hours)),
      _ => None,
    };
    let minutes = match (self.minutes, other.minutes) {
      (Some(self_minutes), Some(other_minutes)) => Some(self_minutes.saturating_sub(other_minutes)),
      _ => None,
    };
    let seconds = match (self.seconds, other.seconds) {
      (Some(self_seconds), Some(other_seconds)) => Some(self_seconds.saturating_sub(other_seconds)),
      _ => None,
    };

    TmsDuration::new(years, months, days, hours, minutes, seconds)
  }

  pub fn add(&self, other: TmsDuration) -> TmsDuration {
    let years = match (self.years, other.years) {
      (Some(self_years), Some(other_years)) => Some(self_years.saturating_add(other_years)),
      _ => None,
    };
    let months = match (self.months, other.months) {
      (Some(self_months), Some(other_months)) => Some(self_months.saturating_add(other_months)),
      _ => None,
    };
    let days = match (self.days, other.days) {
      (Some(self_days), Some(other_days)) => Some(self_days.saturating_add(other_days)),
      _ => None,
    };
    let hours = match (self.hours, other.hours) {
      (Some(self_hours), Some(other_hours)) => Some(self_hours.saturating_add(other_hours)),
      _ => None,
    };
    let minutes = match (self.minutes, other.minutes) {
      (Some(self_minutes), Some(other_minutes)) => Some(self_minutes.saturating_add(other_minutes)),
      _ => None,
    };
    let seconds = match (self.seconds, other.seconds) {
      (Some(self_seconds), Some(other_seconds)) => Some(self_seconds.saturating_add(other_seconds)),
      _ => None,
    };

    TmsDuration::new(years, months, days, hours, minutes, seconds)
  }
}
