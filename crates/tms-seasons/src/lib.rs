//! Robot game seasons: the scoresheet each season uses and how it scores.
//!
//! A season is static data (missions and their fields, which the client renders as a form) plus one scoring
//! function. The same code runs in the browser for the live total and on the server, which recomputes every
//! submitted sheet, so the two can never disagree.

mod bioglow;
pub mod rubric;

use std::collections::BTreeMap;

use serde::{Deserialize, Serialize};

pub use bioglow::BIOGLOW_FOUNDERS;

/// Every season this build knows, newest first.
pub static SEASONS: &[&Season] = &[&BIOGLOW_FOUNDERS];

pub fn by_id(id: &str) -> Option<&'static Season> {
  SEASONS.iter().copied().find(|s| s.id == id)
}

/// One answer on a scoresheet. Stored as plain JSON: `true`, `3`, or `"city"`.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(untagged)]
pub enum Answer {
  Bool(bool),
  Count(u8),
  Choice(String),
}

/// Field id to answer. A missing field means "not answered".
pub type Answers = BTreeMap<String, Answer>;

pub struct Season {
  /// Stored on events and scoresheets, so it never changes once used.
  pub id: &'static str,
  pub name: &'static str,
  /// Bumped whenever fields change, so the server can refuse sheets made with an older form.
  pub schema_version: u16,
  pub missions: &'static [Mission],
  pub max_score: u16,
  /// The judging rubrics this season uses.
  pub rubrics: &'static [rubric::Rubric],
  score: fn(&mut Scoring),
}

pub struct Mission {
  pub id: &'static str,
  pub name: &'static str,
  /// Path under the web client's public folder.
  pub image: Option<&'static str>,
  /// The "No Equipment Constraint" symbol from the official scoresheet.
  pub no_equipment_constraint: bool,
  pub fields: &'static [Field],
}

pub struct Field {
  pub id: &'static str,
  pub label: &'static str,
  pub kind: FieldKind,
  /// The answer a new sheet starts with. `None` means the referee has to choose.
  pub default: Option<DefaultAnswer>,
  /// A yes/no field that must be Yes before this one can be anything but No or 0 (a bonus).
  pub requires: Option<&'static str>,
}

impl Field {
  /// The answer that scores nothing: what a bonus must be while its prerequisite is No.
  pub fn off(&self) -> Option<Answer> {
    match self.kind {
      FieldKind::Bool => Some(Answer::Bool(false)),
      FieldKind::Count { .. } => Some(Answer::Count(0)),
      FieldKind::Choice { .. } => None,
    }
  }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FieldKind {
  Bool,
  Count { max: u8 },
  Choice { options: &'static [ChoiceOption] },
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct ChoiceOption {
  pub key: &'static str,
  pub label: &'static str,
}

/// A default that can live in a `static`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DefaultAnswer {
  Bool(bool),
  Count(u8),
  Choice(&'static str),
}

impl DefaultAnswer {
  pub fn to_answer(self) -> Answer {
    match self {
      DefaultAnswer::Bool(b) => Answer::Bool(b),
      DefaultAnswer::Count(n) => Answer::Count(n),
      DefaultAnswer::Choice(key) => Answer::Choice(key.to_owned()),
    }
  }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Severity {
  /// The sheet can't be submitted.
  Error,
  /// Worth a second look, but the sheet can be submitted.
  Warning,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Issue {
  pub field: String,
  pub message: String,
  pub severity: Severity,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct MissionScore {
  pub mission: String,
  pub points: u16,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ScoreResult {
  pub total: u16,
  pub missions: Vec<MissionScore>,
  pub issues: Vec<Issue>,
}

impl ScoreResult {
  pub fn has_errors(&self) -> bool {
    self.issues.iter().any(|i| i.severity == Severity::Error)
  }

  pub fn issues_for<'a>(&'a self, field: &'a str) -> impl Iterator<Item = &'a Issue> + 'a {
    self.issues.iter().filter(move |i| i.field == field)
  }
}

impl Season {
  pub fn fields(&self) -> impl Iterator<Item = &'static Field> {
    self.missions.iter().flat_map(|m| m.fields.iter())
  }

  pub fn field(&self, id: &str) -> Option<&'static Field> {
    self.fields().find(|f| f.id == id)
  }

  /// A new, empty sheet. Fields without a default are left out until the referee answers them.
  pub fn defaults(&self) -> Answers {
    self
      .fields()
      .filter_map(|f| f.default.map(|d| (f.id.to_owned(), d.to_answer())))
      .collect()
  }

  /// Whether a field's prerequisite is met, so the form can offer it.
  pub fn is_enabled(&self, field: &Field, answers: &Answers) -> bool {
    field
      .requires
      .is_none_or(|req| answers.get(req) == Some(&Answer::Bool(true)))
  }

  /// Sets an answer, and resets any bonus that depends on it when the prerequisite is no longer met.
  pub fn set(&self, answers: &mut Answers, id: &str, answer: Answer) {
    answers.insert(id.to_owned(), answer);
    for dependent in self.fields().filter(|f| f.requires == Some(id)) {
      if !self.is_enabled(dependent, answers)
        && let Some(off) = dependent.off()
      {
        answers.insert(dependent.id.to_owned(), off);
      }
    }
  }

  /// Scores a sheet and lists everything wrong with it. Points are only counted from well-formed answers.
  pub fn score(&self, answers: &Answers) -> ScoreResult {
    let mut scoring = Scoring {
      answers,
      result: ScoreResult {
        total: 0,
        missions: Vec::new(),
        issues: Vec::new(),
      },
    };
    self.check_shape(&mut scoring);
    (self.score)(&mut scoring);
    scoring.result.total = scoring.result.missions.iter().map(|m| m.points).sum();
    scoring.result
  }

  fn check_shape(&self, s: &mut Scoring) {
    for id in s.answers.keys() {
      if self.field(id).is_none() {
        s.error(id, "This question is not on this season's scoresheet.");
      }
    }
    for field in self.fields() {
      let Some(answer) = s.answers.get(field.id) else {
        s.error(field.id, "Not answered.");
        continue;
      };
      let fits = match (field.kind, answer) {
        (FieldKind::Bool, Answer::Bool(_)) => true,
        (FieldKind::Count { max }, Answer::Count(n)) => *n <= max,
        (FieldKind::Choice { options }, Answer::Choice(key)) => options.iter().any(|o| o.key == key),
        _ => false,
      };
      if !fits {
        s.error(field.id, "This answer is not one of the options.");
      } else if !self.is_enabled(field, s.answers) && field.off().as_ref() != Some(answer) {
        let prerequisite = field.requires.and_then(|r| self.field(r)).map_or("", |f| f.label);
        s.error(field.id, &format!("This bonus needs \"{prerequisite}\" first."));
      }
    }
  }
}

/// What a season's scoring function works with. Reading an answer that is missing or malformed gives the
/// zero value; `check_shape` has already reported it.
pub struct Scoring<'a> {
  answers: &'a Answers,
  result: ScoreResult,
}

impl Scoring<'_> {
  pub fn yes(&self, id: &str) -> bool {
    self.answers.get(id) == Some(&Answer::Bool(true))
  }

  pub fn count(&self, id: &str) -> u8 {
    match self.answers.get(id) {
      Some(Answer::Count(n)) => *n,
      _ => 0,
    }
  }

  pub fn choice(&self, id: &str) -> Option<&str> {
    match self.answers.get(id) {
      Some(Answer::Choice(key)) => Some(key),
      _ => None,
    }
  }

  pub fn add(&mut self, mission: &str, points: u16) {
    self.result.missions.push(MissionScore {
      mission: mission.to_owned(),
      points,
    });
  }

  pub fn error(&mut self, field: &str, message: &str) {
    self.issue(field, message, Severity::Error);
  }

  pub fn warn(&mut self, field: &str, message: &str) {
    self.issue(field, message, Severity::Warning);
  }

  fn issue(&mut self, field: &str, message: &str, severity: Severity) {
    self.result.issues.push(Issue {
      field: field.to_owned(),
      message: message.to_owned(),
      severity,
    });
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn registry_finds_seasons_by_id() {
    assert_eq!(by_id("bioglow_founders").map(|s| s.name), Some(BIOGLOW_FOUNDERS.name));
    assert!(by_id("nope").is_none());
  }

  #[test]
  fn every_season_is_well_formed() {
    for season in SEASONS {
      let mut ids = std::collections::BTreeSet::new();
      for field in season.fields() {
        assert!(ids.insert(field.id), "{}: duplicate field {}", season.id, field.id);
        if let Some(req) = field.requires {
          let prerequisite = season
            .field(req)
            .unwrap_or_else(|| panic!("{}: unknown requirement {req}", field.id));
          assert_eq!(
            prerequisite.kind,
            FieldKind::Bool,
            "{}: requirement must be yes/no",
            field.id
          );
        }
        if let (Some(DefaultAnswer::Choice(key)), FieldKind::Choice { options }) = (field.default, field.kind) {
          assert!(
            options.iter().any(|o| o.key == key),
            "{}: default not an option",
            field.id
          );
        }
      }
    }
  }

  #[test]
  fn answers_are_plain_json() {
    let answers: Answers = serde_json::from_str(r#"{"a": true, "b": 3, "c": "city"}"#).unwrap();
    assert_eq!(answers["a"], Answer::Bool(true));
    assert_eq!(answers["b"], Answer::Count(3));
    assert_eq!(answers["c"], Answer::Choice("city".into()));
    assert_eq!(
      serde_json::to_string(&answers).unwrap(),
      r#"{"a":true,"b":3,"c":"city"}"#
    );
  }
}
