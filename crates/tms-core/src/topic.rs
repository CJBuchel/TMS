//! WebSocket subscription topics. On the wire a topic is a plain string: `name`, `name/<id>` or `name?<key>=<id>`.
//! New topics are added here as their phase lands; the string form is the public contract.
//! Every topic holds data for the active event only.

use std::fmt;
use std::str::FromStr;

use serde::{Deserialize, Deserializer, Serialize, Serializer};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub enum Topic {
  /// The active event (zero or one item).
  Event,
  /// Active banners.
  Banners,
  Teams,
  Tables,
  Pods,
  /// Matches, each with its table and team slots.
  Matches,
  /// Judging sessions, each with its pod and team slots.
  JudgingSessions,
  /// Timetable blocks such as lunch and ceremonies.
  Blocks,
  /// The match timer (one item).
  Timer,
  /// Robot game ranking, one item per team.
  Rankings,
  /// Every scoresheet of the event, for referees and head referees.
  Scoresheets,
  /// Station devices (access keys) connected right now, for the head referee and judge advisor.
  Presence,
  /// Each pod's session timer.
  PodTimers,
  /// Every rubric of the event, for judges and the judge advisor.
  Rubrics,
  /// Scores, ranks and awards for the judge advisor (one item).
  Deliberation,
  /// What the awards ceremony has revealed so far (one item).
  Ceremony,
  /// Problems the schedule checks find, for admins, head referees and judge advisors.
  Issues,
}

impl Topic {
  pub const ALL: [Topic; 17] = [
    Topic::Event,
    Topic::Banners,
    Topic::Teams,
    Topic::Tables,
    Topic::Pods,
    Topic::Matches,
    Topic::JudgingSessions,
    Topic::Blocks,
    Topic::Timer,
    Topic::Rankings,
    Topic::Scoresheets,
    Topic::Presence,
    Topic::PodTimers,
    Topic::Rubrics,
    Topic::Deliberation,
    Topic::Ceremony,
    Topic::Issues,
  ];

  pub fn name(self) -> &'static str {
    match self {
      Topic::Event => "event",
      Topic::Banners => "banners",
      Topic::Teams => "teams",
      Topic::Tables => "tables",
      Topic::Pods => "pods",
      Topic::Matches => "matches",
      Topic::JudgingSessions => "judging_sessions",
      Topic::Blocks => "blocks",
      Topic::Timer => "timer",
      Topic::Rankings => "rankings",
      Topic::Scoresheets => "scoresheets",
      Topic::Presence => "presence",
      Topic::PodTimers => "pod_timers",
      Topic::Rubrics => "rubrics",
      Topic::Deliberation => "deliberation",
      Topic::Ceremony => "ceremony",
      Topic::Issues => "issues",
    }
  }
}

impl fmt::Display for Topic {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    f.write_str(self.name())
  }
}

#[derive(Debug, Clone, PartialEq, Eq, thiserror::Error)]
#[error("unknown topic `{0}`")]
pub struct UnknownTopic(pub String);

impl FromStr for Topic {
  type Err = UnknownTopic;

  fn from_str(s: &str) -> Result<Self, Self::Err> {
    Topic::ALL
      .into_iter()
      .find(|t| t.name() == s)
      .ok_or_else(|| UnknownTopic(s.to_owned()))
  }
}

impl Serialize for Topic {
  fn serialize<S: Serializer>(&self, serializer: S) -> Result<S::Ok, S::Error> {
    serializer.collect_str(self)
  }
}

impl<'de> Deserialize<'de> for Topic {
  fn deserialize<D: Deserializer<'de>>(deserializer: D) -> Result<Self, D::Error> {
    let s = String::deserialize(deserializer)?;
    s.parse().map_err(serde::de::Error::custom)
  }
}

#[cfg(feature = "schema")]
impl schemars::JsonSchema for Topic {
  fn schema_name() -> std::borrow::Cow<'static, str> {
    "Topic".into()
  }

  fn json_schema(_: &mut schemars::SchemaGenerator) -> schemars::Schema {
    let names: Vec<&str> = Topic::ALL.iter().map(|t| t.name()).collect();
    schemars::json_schema!({
      "type": "string",
      "description": "Subscription topic: `name`, `name/<id>` or `name?<key>=<id>`.",
      "enum": names
    })
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn every_topic_round_trips_as_its_string() {
    for t in Topic::ALL {
      let json = serde_json::to_string(&t).unwrap();
      assert_eq!(json, format!("\"{}\"", t.name()));
      assert_eq!(serde_json::from_str::<Topic>(&json).unwrap(), t);
    }
  }

  #[test]
  fn unknown_topic_is_an_error() {
    assert!(serde_json::from_str::<Topic>("\"nope\"").is_err());
  }
}
