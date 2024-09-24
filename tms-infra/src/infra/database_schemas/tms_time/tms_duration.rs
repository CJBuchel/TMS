pub struct TmsDuration {
  pub years: Option<i64>,
  pub months: Option<i64>,
  pub days: Option<i64>,
  pub hours: Option<i64>,
  pub minutes: Option<i64>,
  pub seconds: Option<i64>,
}

impl TmsDuration {
  #[flutter_rust_bridge::frb(sync)]
  pub fn new(
    years: Option<i64>,
    months: Option<i64>,
    days: Option<i64>,
    hours: Option<i64>,
    minutes: Option<i64>,
    seconds: Option<i64>,
  ) -> Self {
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
        self.minutes = Some(self.minutes.unwrap_or(0) + seconds / 60);
        self.seconds = Some(seconds % 60);
      }
    }
    if let Some(minutes) = self.minutes {
      if minutes >= 60 {
        self.hours = Some(self.hours.unwrap_or(0) + minutes / 60);
        self.minutes = Some(minutes % 60);
      }
    }
    if let Some(hours) = self.hours {
      if hours >= 24 {
        self.days = Some(self.days.unwrap_or(0) + hours / 24);
        self.hours = Some(hours % 24);
      }
    }
    if let Some(days) = self.days {
      if days >= 30 {
        self.months = Some(self.months.unwrap_or(0) + days / 30);
        self.days = Some(days % 30);
      }
    }
    if let Some(months) = self.months {
      if months >= 12 {
        self.years = Some(self.years.unwrap_or(0) + months / 12);
        self.months = Some(months % 12);
      }
    }
  }

  // in years
  #[flutter_rust_bridge::frb(sync)]
  pub fn in_years(&self) -> i64 {
    self.years.unwrap_or(0)
  }

  // in months
  #[flutter_rust_bridge::frb(sync)]
  pub fn in_months(&self) -> i64 {
    self.in_years() * 12 + self.months.unwrap_or(0)
  }

  // in days
  #[flutter_rust_bridge::frb(sync)]
  pub fn in_days(&self) -> i64 {
    self.in_months() * 30 + self.days.unwrap_or(0)
  }

  // in hours
  #[flutter_rust_bridge::frb(sync)]
  pub fn in_hours(&self) -> i64 {
    self.in_days() * 24 + self.hours.unwrap_or(0)
  }

  // in minutes
  #[flutter_rust_bridge::frb(sync)]
  pub fn in_minutes(&self) -> i64 {
    self.in_hours() * 60 + self.minutes.unwrap_or(0)
  }

  // in seconds
  #[flutter_rust_bridge::frb(sync)]
  pub fn in_seconds(&self) -> i64 {
    self.in_minutes() * 60 + self.seconds.unwrap_or(0)
  }

  // difference
  #[flutter_rust_bridge::frb(sync)]
  pub fn difference(&self, other: TmsDuration) -> TmsDuration {
    // compare only the fields that are present, none otherwise

    let years: Option<i64> = match (self.years, other.years) {
      (Some(self_years), Some(other_years)) => Some(self_years - other_years),
      _ => None,
    };

    let months: Option<i64> = match (self.months, other.months) {
      (Some(self_months), Some(other_months)) => Some(self_months - other_months),
      _ => None,
    };

    let days: Option<i64> = match (self.days, other.days) {
      (Some(self_days), Some(other_days)) => Some(self_days - other_days),
      _ => None,
    };

    let hours: Option<i64> = match (self.hours, other.hours) {
      (Some(self_hours), Some(other_hours)) => Some(self_hours - other_hours),
      _ => None,
    };

    let minutes: Option<i64> = match (self.minutes, other.minutes) {
      (Some(self_minutes), Some(other_minutes)) => Some(self_minutes - other_minutes),
      _ => None,
    };

    let seconds: Option<i64> = match (self.seconds, other.seconds) {
      (Some(self_seconds), Some(other_seconds)) => Some(self_seconds - other_seconds),
      _ => None,
    };

    TmsDuration::new(years, months, days, hours, minutes, seconds)
  }
}