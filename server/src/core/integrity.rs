use crate::generated::common::{IntegrityCode, IntegrityContext, IntegrityMessage, IntegritySeverity};

pub trait IntegrityCodeExt {
  /// Get the string representation of the code (e.g, "E001", "W005")
  fn code_string(&self) -> &'static str;

  /// Get the human-readable message for this code
  fn description(&self) -> &'static str;

  /// Get the severity level
  fn severity(&self) -> IntegritySeverity;
}

impl IntegrityCodeExt for IntegrityCode {
  fn code_string(&self) -> &'static str {
    self.as_str_name()
  }

  fn description(&self) -> &'static str {
    match self {
      IntegrityCode::E000 => "Unknown Error",
      IntegrityCode::E001 => "Team number is missing",
      IntegrityCode::E002 => "Duplicate Team Number",
      IntegrityCode::E003 => "Team has conflicting scores",
      IntegrityCode::E004 => "Table does not exist in event",
      IntegrityCode::E005 => "Team in match does not exist in this event",
      IntegrityCode::E006 => "Duplicate match number",
      IntegrityCode::E007 => "Team has fewer matches than the maximum number of rounds",
      IntegrityCode::E008 => "Pod does not exist in event",
      IntegrityCode::E009 => "Team in pod does not exist in this event",
      IntegrityCode::E010 => "Team has more than one judging session",
      IntegrityCode::E011 => "Team is not in any judging sessions",
      IntegrityCode::E012 => "Duplicate session number",
      IntegrityCode::E013 => "Team has match overlapping with Judging session",
      IntegrityCode::W000 => "Unknown Warning",
      IntegrityCode::W001 => "Team name is missing",
      IntegrityCode::W002 => "Duplicate Team Name",
      IntegrityCode::W003 => "Team has a round 0 score",
      IntegrityCode::W004 => "No tables or teams found in match",
      IntegrityCode::W005 => "Match is complete but score not submitted",
      IntegrityCode::W006 => "Match is not complete but score submitted",
      IntegrityCode::W007 => "Blank table in match",
      IntegrityCode::W008 => "No team on table",
      IntegrityCode::W009 => "Team has judging session within 10 minutes of match",
      IntegrityCode::W010 => "No pods or teams found in sessions",
      IntegrityCode::W011 => "Session Complete, but no core values score submitted",
      IntegrityCode::W012 => "Session Complete, but no innovation score submitted",
      IntegrityCode::W013 => "Session Complete, but no robot design score submitted",
      IntegrityCode::W014 => "Session not Complete, but core values score submitted",
      IntegrityCode::W015 => "Session not Complete, but innovation score submitted",
      IntegrityCode::W016 => "Session not Complete, but robot design score submitted",
      IntegrityCode::W017 => "Blank pod in session",
      IntegrityCode::W018 => "No team in pod",
    }
  }

  fn severity(&self) -> IntegritySeverity {
    let code_num = *self as i32;
    if code_num < 1000 { IntegritySeverity::Error } else { IntegritySeverity::Warning }
  }
}

/// Builder for creating integrity messages with formatted output
pub struct IntegrityMessageBuilder {
  code: IntegrityCode,
  context: IntegrityContext,
}

impl IntegrityMessageBuilder {
  pub fn new(code: IntegrityCode) -> Self {
    Self { code, context: IntegrityContext::default() }
  }

  #[must_use]
  pub fn keys(mut self, keys: Vec<String>) -> Self {
    self.context.context_keys = keys;
    self
  }

  #[must_use]
  pub fn team(mut self, team_number: impl Into<String>) -> Self {
    self.context.team_number = Some(team_number.into());
    self
  }

  #[must_use]
  pub fn match_num(mut self, match_number: impl Into<String>) -> Self {
    self.context.match_number = Some(match_number.into());
    self
  }

  #[must_use]
  pub fn session(mut self, session_number: impl Into<String>) -> Self {
    self.context.session_number = Some(session_number.into());
    self
  }

  #[must_use]
  pub fn table(mut self, table_name: impl Into<String>) -> Self {
    self.context.table_name = Some(table_name.into());
    self
  }

  #[must_use]
  pub fn pod(mut self, pod_name: impl Into<String>) -> Self {
    self.context.pod_name = Some(pod_name.into());
    self
  }

  fn format_message(&self) -> String {
    let mut parts = vec![format!("[{}]:", self.code.code_string())];

    if let Some(team) = &self.context.team_number {
      parts.push(format!(" Team: {},", team));
    }
    if let Some(m) = &self.context.match_number {
      parts.push(format!(" Match: {},", m));
    }
    if let Some(s) = &self.context.session_number {
      parts.push(format!(" Session: {},", s));
    }
    if let Some(t) = &self.context.table_name {
      parts.push(format!(" Table: {},", t));
    }
    if let Some(p) = &self.context.pod_name {
      parts.push(format!(" Pod: {},", p));
    }

    // Remove trailing comma from last context item
    if let Some(last) = parts.last_mut() {
      *last = last.trim_end_matches(',').to_string();
    }

    parts.push(format!(" - {}", self.code.description()));
    parts.join("")
  }

  /// Build the message with formatting
  pub fn build(&self) -> IntegrityMessage {
    let formatted_message = self.format_message();

    IntegrityMessage {
      code: self.code as i32,
      severity: self.code.severity() as i32,
      context: Some(self.context.clone()),
      formatted_message,
    }
  }
}
