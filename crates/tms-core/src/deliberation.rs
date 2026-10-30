//! Deliberation: area scores and ranks exactly as the Official Judging Spreadsheet computes them, and award
//! allocation in the order and with the eligibility rules of the official Awards and Allocation guide.

use std::collections::BTreeMap;
use std::fmt;

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use tms_seasons::rubric::RubricTotals;
use uuid::Uuid;

use crate::judging::Nomination;

/// A score in hundredths of a point. Gracious Professionalism from four or five matches is scaled by 0.75 or
/// 0.6, so Core Values can be fractional.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, Default, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(transparent)]
pub struct Hundredths(pub u32);

impl fmt::Display for Hundredths {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    let (whole, part) = (self.0 / 100, self.0 % 100);
    match part {
      0 => write!(f, "{whole}"),
      p if p % 10 == 0 => write!(f, "{whole}.{}", p / 10),
      p => write!(f, "{whole}.{p:02}"),
    }
  }
}

/// What is known about one team before ranking.
#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct TeamInputs {
  pub team_id: Uuid,
  /// From the accepted rubric, if any.
  pub rubric: Option<RubricTotals>,
  /// Gracious Professionalism from each published ranking match, in round order.
  pub gp: Vec<u8>,
  /// Each published ranking match score, in round order.
  pub robot_game: Vec<u16>,
}

/// One team's line of the spreadsheet's Results and Rankings page.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct TeamScores {
  pub team_id: Uuid,
  pub innovation_project: Option<u16>,
  pub robot_design: Option<u16>,
  /// Core Values rows from both rubrics plus the Gracious Professionalism score.
  pub core_values: Option<Hundredths>,
  pub gracious_professionalism: Option<Hundredths>,
  /// Best ranking match score.
  pub robot_game: Option<u16>,
  pub robot_game_scores: Vec<u16>,
  pub innovation_project_rank: u32,
  pub robot_design_rank: u32,
  pub core_values_rank: u32,
  pub robot_game_rank: u32,
  /// Sum of the four ranks; lowest is best.
  pub champions_score: u32,
  pub champions_rank: u32,
}

/// The spreadsheet holds five robot game scores and five Gracious Professionalism scores per team.
const MATCHES: usize = 5;

/// Gracious Professionalism as the spreadsheet scores it: one to three scores add up, four are scaled by 0.75 and
/// five by 0.6.
pub fn gp_score(gp: &[u8]) -> Option<Hundredths> {
  let gp = &gp[..gp.len().min(MATCHES)];
  let factor = match gp.len() {
    0 => return None,
    1..=3 => 100,
    4 => 75,
    _ => 60,
  };
  Some(Hundredths(gp.iter().map(|g| u32::from(*g)).sum::<u32>() * factor))
}

/// The spreadsheet's robot game tiebreak: the best score, then the second, third, fourth and fifth, folded into
/// one number with the spreadsheet's own weights so ties and near-ties land exactly where they do in Excel.
// The weights are written as in the spreadsheet's formula.
#[allow(clippy::unreadable_literal)]
fn robot_game_key(scores: &[u16]) -> f64 {
  let mut s = [0.0_f64; MATCHES];
  let mut sorted: Vec<u16> = scores.iter().take(MATCHES).copied().collect();
  sorted.sort_unstable_by(|a, b| b.cmp(a));
  for (slot, score) in s.iter_mut().zip(sorted) {
    *slot = f64::from(score);
  }
  s[0] + 0.0001 * s[1] + 0.0000001 * s[2] + 0.00000000001 * s[3] + 0.00000000000001 * s[4]
}

fn count_u32(n: usize) -> u32 {
  u32::try_from(n).unwrap_or(u32::MAX)
}

/// `RANK.EQ` descending among the teams that have a score; a team without one ranks below every team.
fn area_ranks<T: PartialOrd>(values: &[Option<T>]) -> Vec<u32> {
  let missing = count_u32(values.len()) + 1;
  values
    .iter()
    .map(|v| match v {
      None => missing,
      Some(v) => 1 + count_u32(values.iter().flatten().filter(|o| *o > v).count()),
    })
    .collect()
}

/// Every team's area scores and ranks, and Champion's score and rank.
pub fn team_scores(teams: &[TeamInputs]) -> Vec<TeamScores> {
  let ip: Vec<Option<u16>> = teams.iter().map(|t| t.rubric.map(|r| r.innovation_project)).collect();
  let rd: Vec<Option<u16>> = teams.iter().map(|t| t.rubric.map(|r| r.robot_design)).collect();
  let gp: Vec<Option<Hundredths>> = teams.iter().map(|t| gp_score(&t.gp)).collect();
  let cv: Vec<Option<Hundredths>> = teams
    .iter()
    .zip(&gp)
    .map(|(t, gp)| {
      t.rubric
        .map(|r| Hundredths(u32::from(r.core_values_rows) * 100 + gp.unwrap_or_default().0))
    })
    .collect();
  // Every team has a robot game key; a team that hasn't played shares the last rank with the others at zero.
  let rg: Vec<Option<f64>> = teams.iter().map(|t| Some(robot_game_key(&t.robot_game))).collect();
  let (project_rank, design_rank, values_rank, game_rank) =
    (area_ranks(&ip), area_ranks(&rd), area_ranks(&cv), area_ranks(&rg));
  let champions: Vec<u32> = (0..teams.len())
    .map(|i| project_rank[i] + design_rank[i] + values_rank[i] + game_rank[i])
    .collect();
  (0..teams.len())
    .map(|i| TeamScores {
      team_id: teams[i].team_id,
      innovation_project: ip[i],
      robot_design: rd[i],
      core_values: cv[i],
      gracious_professionalism: gp[i],
      robot_game: teams[i].robot_game.iter().max().copied(),
      robot_game_scores: teams[i].robot_game.clone(),
      innovation_project_rank: project_rank[i],
      robot_design_rank: design_rank[i],
      core_values_rank: values_rank[i],
      robot_game_rank: game_rank[i],
      champions_score: champions[i],
      champions_rank: 1 + count_u32(champions.iter().filter(|c| **c < champions[i]).count()),
    })
    .collect()
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord, Serialize, Deserialize)]
#[cfg_attr(feature = "sqlx", derive(sqlx::Type))]
#[cfg_attr(feature = "sqlx", sqlx(type_name = "award_kind", rename_all = "snake_case"))]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(rename_all = "snake_case")]
pub enum AwardKind {
  Champions,
  CoreValues,
  InnovationProject,
  RobotDesign,
  RobotPerformance,
  CoachMentor,
  EngineeringExcellence,
  Breakthrough,
  RisingAllStar,
  Motivate,
  Peer,
  Local,
}

impl AwardKind {
  pub const ALL: [AwardKind; 12] = [
    AwardKind::Champions,
    AwardKind::CoreValues,
    AwardKind::InnovationProject,
    AwardKind::RobotDesign,
    AwardKind::RobotPerformance,
    AwardKind::CoachMentor,
    AwardKind::EngineeringExcellence,
    AwardKind::Breakthrough,
    AwardKind::RisingAllStar,
    AwardKind::Motivate,
    AwardKind::Peer,
    AwardKind::Local,
  ];

  pub fn label(self) -> &'static str {
    match self {
      AwardKind::Champions => "Champion's",
      AwardKind::CoreValues => "Core Values",
      AwardKind::InnovationProject => "Innovation Project",
      AwardKind::RobotDesign => "Robot Design",
      AwardKind::RobotPerformance => "Robot Performance",
      AwardKind::CoachMentor => "Coach/Mentor",
      AwardKind::EngineeringExcellence => "Engineering Excellence",
      AwardKind::Breakthrough => "Breakthrough",
      AwardKind::RisingAllStar => "Rising All-Star",
      AwardKind::Motivate => "Motivate",
      AwardKind::Peer => "Peer",
      AwardKind::Local => "Local award",
    }
  }

  /// Every event presents these.
  pub fn required(self) -> bool {
    matches!(
      self,
      AwardKind::Champions
        | AwardKind::CoreValues
        | AwardKind::InnovationProject
        | AwardKind::RobotDesign
        | AwardKind::RobotPerformance
        | AwardKind::CoachMentor
    )
  }

  /// A team wins at most one judged award. Robot Performance, Coach/Mentor and Peer don't count, and local awards
  /// follow the tournament director's own rules.
  pub fn judged(self) -> bool {
    !matches!(
      self,
      AwardKind::RobotPerformance | AwardKind::CoachMentor | AwardKind::Peer | AwardKind::Local
    )
  }

  /// The most places the guide allows: a winner and up to three finalists, up to six Coach/Mentor winners, up to
  /// three for optional awards.
  pub fn max_places(self) -> u8 {
    match self {
      AwardKind::Champions
      | AwardKind::CoreValues
      | AwardKind::InnovationProject
      | AwardKind::RobotDesign
      | AwardKind::RobotPerformance => 4,
      AwardKind::CoachMentor => 6,
      AwardKind::Local => 10,
      _ => 3,
    }
  }

  /// Awards whose candidates the judges select on the rubric.
  pub fn nomination(self) -> Option<Nomination> {
    match self {
      AwardKind::Breakthrough => Some(Nomination::Breakthrough),
      AwardKind::RisingAllStar => Some(Nomination::RisingAllStar),
      AwardKind::Motivate => Some(Nomination::Motivate),
      _ => None,
    }
  }

  /// Where a new award goes in the ceremony: smaller awards first, Champion's last.
  pub fn ceremony_order(self) -> i32 {
    match self {
      AwardKind::Local => 10,
      AwardKind::CoachMentor => 20,
      AwardKind::Peer => 30,
      AwardKind::Motivate => 40,
      AwardKind::RisingAllStar => 50,
      AwardKind::Breakthrough => 60,
      AwardKind::EngineeringExcellence => 70,
      AwardKind::RobotPerformance => 80,
      AwardKind::RobotDesign => 90,
      AwardKind::InnovationProject => 100,
      AwardKind::CoreValues => 110,
      AwardKind::Champions => 120,
    }
  }
}

/// An award this event presents, with how many places.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct Award {
  pub id: Uuid,
  pub event_id: Uuid,
  pub kind: AwardKind,
  pub name: String,
  pub places: u8,
  /// Ceremony order.
  pub sort_order: i32,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct AwardWinner {
  pub award_id: Uuid,
  pub team_id: Uuid,
  pub place: u8,
  /// Why the award skipped a higher-ranked eligible team; required when it did.
  pub note: String,
  pub assigned_by: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct Finalized {
  pub at: DateTime<Utc>,
  pub by: String,
}

/// Everything the judge advisor deliberates with, kept current on the `deliberation` topic.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct Deliberation {
  pub event_id: Uuid,
  /// In team number order.
  pub teams: Vec<TeamScores>,
  /// Candidates the judges selected on accepted rubrics.
  pub nominations: BTreeMap<Uuid, Vec<Nomination>>,
  pub awards: Vec<Award>,
  pub winners: Vec<AwardWinner>,
  /// How many teams advance, from the event settings.
  pub advancement_slots: u32,
  /// Advancing teams, in order.
  pub advancing: Vec<Uuid>,
  pub finalized: Option<Finalized>,
}

/// One allocation step: a place of an award, or advancement.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(tag = "step", rename_all = "snake_case")]
pub enum Step {
  Award { award_id: Uuid, place: u8 },
  Advancement,
}

/// A team as one step considers it.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Candidate {
  pub team_id: Uuid,
  /// The rank this step goes by; `None` where the judges choose (Coach/Mentor, Peer, local awards).
  pub rank: Option<u32>,
  /// Why the team can't take this step, if it can't.
  pub ineligible: Option<String>,
}

pub fn place_label(place: u8) -> &'static str {
  match place {
    1 => "1st",
    2 => "2nd",
    3 => "3rd",
    4 => "4th",
    5 => "5th",
    6 => "6th",
    7 => "7th",
    8 => "8th",
    9 => "9th",
    _ => "10th",
  }
}

impl Deliberation {
  pub fn award(&self, id: Uuid) -> Option<&Award> {
    self.awards.iter().find(|a| a.id == id)
  }

  fn of_kind(&self, kind: AwardKind) -> impl Iterator<Item = &Award> {
    self.awards.iter().filter(move |a| a.kind == kind)
  }

  pub fn winner(&self, award_id: Uuid, place: u8) -> Option<&AwardWinner> {
    self.winners.iter().find(|w| w.award_id == award_id && w.place == place)
  }

  pub fn scores(&self, team_id: Uuid) -> Option<&TeamScores> {
    self.teams.iter().find(|t| t.team_id == team_id)
  }

  /// The allocation steps in the guide's order: Champion's, advancement, Robot Performance, then Core Values,
  /// Innovation Project and Robot Design place by place, Coach/Mentor, Engineering Excellence, Breakthrough,
  /// Rising All-Star and Motivate, Peer, and local awards.
  pub fn steps(&self) -> Vec<Step> {
    let mut steps = Vec::new();
    let all_places = |steps: &mut Vec<Step>, award: &Award| {
      steps.extend((1..=award.places).map(|place| Step::Award {
        award_id: award.id,
        place,
      }));
    };
    for award in self.of_kind(AwardKind::Champions) {
      all_places(&mut steps, award);
    }
    if self.advancement_slots > 0 {
      steps.push(Step::Advancement);
    }
    for award in self.of_kind(AwardKind::RobotPerformance) {
      all_places(&mut steps, award);
    }
    let areas = [
      AwardKind::CoreValues,
      AwardKind::InnovationProject,
      AwardKind::RobotDesign,
    ];
    let most = areas
      .iter()
      .flat_map(|k| self.of_kind(*k))
      .map(|a| a.places)
      .max()
      .unwrap_or(0);
    for place in 1..=most {
      for kind in areas {
        for award in self.of_kind(kind).filter(|a| a.places >= place) {
          steps.push(Step::Award {
            award_id: award.id,
            place,
          });
        }
      }
    }
    for kind in [
      AwardKind::CoachMentor,
      AwardKind::EngineeringExcellence,
      AwardKind::Breakthrough,
      AwardKind::RisingAllStar,
      AwardKind::Motivate,
      AwardKind::Peer,
    ] {
      for award in self.of_kind(kind) {
        all_places(&mut steps, award);
      }
    }
    let mut local: Vec<&Award> = self.of_kind(AwardKind::Local).collect();
    local.sort_by_key(|a| a.sort_order);
    for award in local {
      all_places(&mut steps, award);
    }
    steps
  }

  pub fn step_title(&self, step: Step) -> String {
    match step {
      Step::Advancement => "Advancement".into(),
      Step::Award { award_id, place } => match self.award(award_id) {
        Some(a) if a.places > 1 => format!("{} {}", a.name, place_label(place)),
        Some(a) => a.name.clone(),
        None => "Removed award".into(),
      },
    }
  }

  /// Whether the step is settled: its place has a winner, or every advancement slot is taken.
  pub fn step_done(&self, step: Step) -> bool {
    match step {
      Step::Advancement => self.advancing.len() >= self.advancement_slots as usize,
      Step::Award { award_id, place } => self.winner(award_id, place).is_some(),
    }
  }

  /// The first step not yet settled.
  pub fn current_step(&self) -> Option<Step> {
    self.steps().into_iter().find(|s| !self.step_done(*s))
  }

  /// The judged award a team already holds, other than `except`.
  fn judged_award_held(&self, team_id: Uuid, except: Uuid) -> Option<(&Award, u8)> {
    self
      .winners
      .iter()
      .filter(|w| w.team_id == team_id && w.award_id != except)
      .find_map(|w| self.award(w.award_id).filter(|a| a.kind.judged()).map(|a| (a, w.place)))
  }

  /// Why `team_id` can't take this step, if it can't.
  pub fn ineligible(&self, step: Step, team_id: Uuid) -> Option<String> {
    let Step::Award { award_id, .. } = step else {
      return None;
    };
    let award = self.award(award_id)?;
    if let Some(w) = self
      .winners
      .iter()
      .find(|w| w.award_id == award_id && w.team_id == team_id)
    {
      return Some(format!("Already {} for this award", place_label(w.place)));
    }
    if award.kind.judged()
      && let Some((held, place)) = self.judged_award_held(team_id, award_id)
    {
      return Some(if held.places > 1 {
        format!("Has {} {}", held.name, place_label(place))
      } else {
        format!("Has {}", held.name)
      });
    }
    if let Some(nomination) = award.kind.nomination()
      && !self.nominations.get(&team_id).is_some_and(|n| n.contains(&nomination))
    {
      return Some("Not selected by the judges".into());
    }
    None
  }

  /// Every team in the order this step considers them, best first, with the rank it goes by.
  pub fn candidates(&self, step: Step) -> Vec<Candidate> {
    let kind = match step {
      Step::Advancement => Some(AwardKind::Champions),
      Step::Award { award_id, .. } => self.award(award_id).map(|a| a.kind),
    };
    let key = |t: &TeamScores| -> Option<u32> {
      match kind? {
        AwardKind::Champions | AwardKind::EngineeringExcellence | AwardKind::RisingAllStar | AwardKind::Motivate => {
          Some(t.champions_rank)
        }
        AwardKind::RobotPerformance => Some(t.robot_game_rank),
        AwardKind::CoreValues => Some(t.core_values_rank),
        AwardKind::InnovationProject => Some(t.innovation_project_rank),
        AwardKind::RobotDesign => Some(t.robot_design_rank),
        AwardKind::Breakthrough => [
          t.core_values_rank,
          t.innovation_project_rank,
          t.robot_design_rank,
          t.robot_game_rank,
        ]
        .into_iter()
        .min(),
        AwardKind::CoachMentor | AwardKind::Peer | AwardKind::Local => None,
      }
    };
    let mut teams: Vec<&TeamScores> = self.teams.iter().collect();
    teams.sort_by_key(|t| (key(t).unwrap_or(0), t.champions_rank));
    teams
      .into_iter()
      .map(|t| Candidate {
        team_id: t.team_id,
        rank: key(t),
        ineligible: self.ineligible(step, t.team_id),
      })
      .collect()
  }

  /// The best-ranked team that can take this step, when the step goes by a rank.
  pub fn top_candidate(&self, step: Step) -> Option<Uuid> {
    self
      .candidates(step)
      .into_iter()
      .find(|c| c.rank.is_some() && c.ineligible.is_none())
      .map(|c| c.team_id)
  }

  /// Required award places still without a winner.
  pub fn open_required(&self) -> Vec<String> {
    self
      .steps()
      .into_iter()
      .filter(|s| match s {
        Step::Award { award_id, .. } => self.award(*award_id).is_some_and(|a| a.kind.required()),
        Step::Advancement => true,
      })
      .filter(|s| !self.step_done(*s))
      .map(|s| self.step_title(s))
      .collect()
  }

  /// How many teams win at least one award; the guide aims for 30 to 50 percent.
  pub fn teams_awarded(&self) -> usize {
    let mut teams: Vec<Uuid> = self.winners.iter().map(|w| w.team_id).collect();
    teams.sort_unstable();
    teams.dedup();
    teams.len()
  }
}

/// What the venue screen shows during the awards ceremony: only what has been revealed.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct Ceremony {
  pub event_id: Uuid,
  /// How many slides have been revealed.
  pub shown: u32,
  pub total: u32,
  /// The revealed slides, in ceremony order.
  pub slides: Vec<CeremonySlide>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct CeremonySlide {
  pub title: String,
  /// Lowest place first, as they are read out.
  pub winners: Vec<CeremonyWinner>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct CeremonyWinner {
  /// "1st", "2nd"; empty for single-place awards and advancement.
  pub place: String,
  pub team_number: String,
  pub team_name: String,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(rename_all = "snake_case")]
pub enum CeremonyAction {
  Next,
  Previous,
  Restart,
}

/// The ceremony's slides: each award with winners in ceremony order, then the advancing teams.
pub fn ceremony_slides(d: &Deliberation, team: impl Fn(Uuid) -> (String, String)) -> Vec<CeremonySlide> {
  let mut awards: Vec<&Award> = d.awards.iter().collect();
  awards.sort_by_key(|a| a.sort_order);
  let mut slides: Vec<CeremonySlide> = awards
    .into_iter()
    .filter_map(|award| {
      let mut winners: Vec<&AwardWinner> = d.winners.iter().filter(|w| w.award_id == award.id).collect();
      if winners.is_empty() {
        return None;
      }
      winners.sort_by_key(|w| std::cmp::Reverse(w.place));
      Some(CeremonySlide {
        title: award.name.clone(),
        winners: winners
          .into_iter()
          .map(|w| {
            let (team_number, team_name) = team(w.team_id);
            CeremonyWinner {
              place: if award.places > 1 {
                place_label(w.place).to_owned()
              } else {
                String::new()
              },
              team_number,
              team_name,
            }
          })
          .collect(),
      })
    })
    .collect();
  if !d.advancing.is_empty() {
    slides.push(CeremonySlide {
      title: "Advancing to the next level".into(),
      winners: d
        .advancing
        .iter()
        .map(|id| {
          let (team_number, team_name) = team(*id);
          CeremonyWinner {
            place: String::new(),
            team_number,
            team_name,
          }
        })
        .collect(),
    });
  }
  slides
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct NewAward {
  pub kind: AwardKind,
  /// Defaults to the kind's name; required for local awards.
  #[serde(default)]
  pub name: String,
  pub places: u8,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Default)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct AwardPatch {
  pub name: Option<String>,
  pub places: Option<u8>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct AssignRequest {
  pub team_id: Uuid,
  pub place: u8,
  #[serde(default)]
  pub note: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
pub struct AdvancementRequest {
  pub team_ids: Vec<Uuid>,
}

#[cfg(test)]
mod tests {
  use super::*;

  fn team(id: u128, ip: u16, rd: u16, cv: u16, gp: &[u8], rg: &[u16]) -> TeamInputs {
    TeamInputs {
      team_id: Uuid::from_u128(id),
      rubric: Some(RubricTotals {
        innovation_project: ip,
        robot_design: rd,
        core_values_rows: cv,
      }),
      gp: gp.to_vec(),
      robot_game: rg.to_vec(),
    }
  }

  #[test]
  fn gp_as_the_spreadsheet_scores_it() {
    assert_eq!(gp_score(&[3, 3, 3]), Some(Hundredths(900)));
    assert_eq!(
      gp_score(&[4, 4]),
      Some(Hundredths(800)),
      "two scores add up, not scaled"
    );
    assert_eq!(gp_score(&[2, 3, 3, 4]), Some(Hundredths(900)));
    assert_eq!(gp_score(&[3, 3, 3, 3, 4]), Some(Hundredths(960)));
    assert_eq!(gp_score(&[]), None);
    assert_eq!(Hundredths(3875).to_string(), "38.75");
    assert_eq!(Hundredths(3880).to_string(), "38.8");
    assert_eq!(Hundredths(3900).to_string(), "39");
  }

  #[test]
  fn champions_score_is_the_sum_of_ranks() {
    let teams = [
      team(1, 30, 30, 30, &[3, 3, 3], &[300, 100, 0]),
      team(2, 35, 25, 30, &[3, 3, 3], &[200]),
      team(3, 20, 20, 20, &[2, 2, 2], &[400, 10]),
      TeamInputs {
        team_id: Uuid::from_u128(4),
        ..TeamInputs::default()
      },
    ];
    let scores = team_scores(&teams);
    assert_eq!(scores[0].core_values, Some(Hundredths(3900)));
    let ranks: Vec<(u32, u32, u32, u32)> = scores
      .iter()
      .map(|s| {
        (
          s.innovation_project_rank,
          s.robot_design_rank,
          s.core_values_rank,
          s.robot_game_rank,
        )
      })
      .collect();
    assert_eq!(
      ranks,
      [(2, 1, 1, 2), (1, 2, 1, 3), (3, 3, 3, 1), (5, 5, 5, 4)],
      "ties share, a missing area is n + 1, a team without matches is last at zero"
    );
    let champions: Vec<(u32, u32)> = scores.iter().map(|s| (s.champions_score, s.champions_rank)).collect();
    assert_eq!(champions, [(6, 1), (7, 2), (10, 3), (19, 4)]);
  }

  #[test]
  fn robot_game_ties_break_on_the_next_best_score() {
    let teams = [
      team(1, 0, 0, 0, &[], &[200, 150, 100]),
      team(2, 0, 0, 0, &[], &[150, 200, 120]),
      team(3, 0, 0, 0, &[], &[200, 150, 100]),
    ];
    let ranks: Vec<u32> = team_scores(&teams).iter().map(|s| s.robot_game_rank).collect();
    assert_eq!(ranks, [2, 1, 2]);
  }

  /// One team's line as the spreadsheet computes it.
  #[derive(Debug, PartialEq)]
  struct OjsRow {
    core_values_score: Option<f64>,
    ip_rank: f64,
    rd_rank: f64,
    cv_rank: f64,
    rg_rank: f64,
    champions_score: f64,
    champions_rank: f64,
  }

  /// The Official Judging Spreadsheet's formulas transcribed cell by cell over its 200-row tables.
  #[allow(clippy::cast_precision_loss, clippy::unreadable_literal, clippy::similar_names)]
  fn ojs(teams: &[TeamInputs]) -> Vec<OjsRow> {
    const ROWS: usize = 200;
    // NumberOfTeams = COUNTA(OfficialTeamList[Team Number])
    let n = teams.len() as f64;
    // RANK.EQ(x, ref, 0): 1 + the count of numbers in ref greater than x; blanks and text are skipped.
    let rank_eq = |x: f64, column: &[Option<f64>]| 1.0 + column.iter().flatten().filter(|v| **v > x).count() as f64;
    // The rubric input tables hold the judged teams in their first rows; the empty rows sum to 0.
    let judged: Vec<usize> = (0..teams.len()).filter(|i| teams[*i].rubric.is_some()).collect();
    let column = |value: &dyn Fn(&TeamInputs) -> f64| -> Vec<Option<f64>> {
      let mut c = vec![Some(0.0); ROWS];
      for (row, i) in judged.iter().enumerate() {
        c[row] = Some(value(&teams[*i]));
      }
      c
    };
    let ip_score = column(&|t| f64::from(t.rubric.unwrap().innovation_project));
    let rd_score = column(&|t| f64::from(t.rubric.unwrap().robot_design));
    // Gracious Professionalism Score: by how many of the five cells are empty; "" when the first is.
    let gp_score_cell = |gp: &[u8]| -> Option<f64> {
      let cells: Vec<Option<f64>> = (0..5).map(|k| gp.get(k).map(|g| f64::from(*g))).collect();
      cells[0]?;
      let empty = cells.iter().filter(|c| c.is_none()).count();
      let total: f64 = cells.iter().flatten().sum();
      match empty {
        2..=4 => Some(total),
        1 => Some(total * 0.75),
        0 => Some(total * 0.6),
        _ => None,
      }
    };
    // Core Values Score = SUM(the ten CV rows, Gracious Professionalism Score); SUM skips "".
    let cv_score = column(&|t| f64::from(t.rubric.unwrap().core_values_rows) + gp_score_cell(&t.gp).unwrap_or(0.0));
    // [Area] Rank = IF(team > 0, MIN(RANK.EQ(score, scores, 0), NumberOfTeams), NumberOfTeams + 1), and
    // Results and Rankings looks it up with NumberOfTeams + 1 for a team not in the table.
    let area_rank = |i: usize, scores: &[Option<f64>]| match judged.iter().position(|j| *j == i) {
      Some(row) => rank_eq(scores[row].unwrap(), scores).min(n),
      None => n + 1.0,
    };
    // Max Robot Game Score = LARGE(1) + 0.0001 * LARGE(2) + 0.0000001 * LARGE(3) + 0.00000000001 * LARGE(4)
    //   + 0.00000000000001 * LARGE(5) over the five score cells, each 0 when blank or not entered.
    let max_score: Vec<Option<f64>> = teams
      .iter()
      .map(|t| {
        let mut s: Vec<f64> = (0..5)
          .map(|k| t.robot_game.get(k).map_or(0.0, |v| f64::from(*v)))
          .collect();
        s.sort_by(|a, b| b.total_cmp(a));
        Some(s[0] + 0.0001 * s[1] + 0.0000001 * s[2] + 0.00000000001 * s[3] + 0.00000000000001 * s[4])
      })
      .collect();
    let mut rows: Vec<OjsRow> = (0..teams.len())
      .map(|i| {
        let (ip_rank, rd_rank, cv_rank) = (
          area_rank(i, &ip_score),
          area_rank(i, &rd_score),
          area_rank(i, &cv_score),
        );
        // Robot Game Rank = RANK.EQ(Max Robot Game Score, TournamentData[Max Robot Game Score])
        let rg_rank = rank_eq(max_score[i].unwrap(), &max_score);
        OjsRow {
          core_values_score: judged.iter().position(|j| *j == i).and_then(|row| cv_score[row]),
          ip_rank,
          rd_rank,
          cv_rank,
          rg_rank,
          champions_score: cv_rank + ip_rank + rd_rank + rg_rank,
          champions_rank: 0.0,
        }
      })
      .collect();
    // Champion's Rank = RANK(M, M$3:M$202, 1) - COUNTIF(M$3:M$202, 0); blank rows hold "" and are skipped.
    let champions: Vec<f64> = rows.iter().map(|r| r.champions_score).collect();
    let zeros = champions.iter().filter(|c| **c == 0.0).count() as f64;
    for row in &mut rows {
      row.champions_rank = 1.0 + champions.iter().filter(|c| **c < row.champions_score).count() as f64 - zeros;
    }
    rows
  }

  #[test]
  fn matches_the_official_judging_spreadsheet() {
    let mut seed: u64 = 0x0b5;
    let mut next = |options: u64| {
      seed = seed
        .wrapping_mul(6_364_136_223_846_793_005)
        .wrapping_add(1_442_695_040_888_963_407);
      (seed >> 33) % options
    };
    for _ in 0..3_000 {
      let count = 1 + next(40);
      let teams: Vec<TeamInputs> = (0..count)
        .map(|i| {
          // Levels are mostly 2 and 3, so totals tie often.
          let judged = next(8) != 0;
          let mut level = || u16::try_from(2 + next(2) + u64::from(next(8) == 0)).unwrap();
          let rubric = judged.then(|| {
            let cv: u16 = (0..10).map(|_| level()).sum();
            let ip_rest: u16 = (0..5).map(|_| level()).sum();
            let rd_rest: u16 = (0..5).map(|_| level()).sum();
            RubricTotals {
              innovation_project: cv / 2 + ip_rest,
              robot_design: cv - cv / 2 + rd_rest,
              core_values_rows: cv,
            }
          });
          let gp = (0..next(6)).map(|_| u8::try_from(2 + next(3)).unwrap()).collect();
          let robot_game = (0..next(6)).map(|_| u16::try_from(next(25) * 25).unwrap()).collect();
          TeamInputs {
            team_id: Uuid::from_u128(u128::from(i)),
            rubric,
            gp,
            robot_game,
          }
        })
        .collect();
      let ours: Vec<OjsRow> = team_scores(&teams)
        .iter()
        .map(|s| OjsRow {
          core_values_score: s.core_values.map(|c| f64::from(c.0) / 100.0),
          ip_rank: f64::from(s.innovation_project_rank),
          rd_rank: f64::from(s.robot_design_rank),
          cv_rank: f64::from(s.core_values_rank),
          rg_rank: f64::from(s.robot_game_rank),
          champions_score: f64::from(s.champions_score),
          champions_rank: f64::from(s.champions_rank),
        })
        .collect();
      let mut spreadsheet = ojs(&teams);
      for row in &mut spreadsheet {
        row.core_values_score = row.core_values_score.map(|c| (c * 100.0).round() / 100.0);
      }
      assert_eq!(ours, spreadsheet, "{teams:?}");
    }
  }

  fn deliberation(n: u128) -> Deliberation {
    let inputs: Vec<TeamInputs> = (1..=n)
      .map(|i| {
        let s = u16::try_from(40 - i).unwrap();
        team(i, s, s, 20, &[3, 3, 3], &[s * 10])
      })
      .collect();
    let award = |id: u128, kind: AwardKind, places: u8| Award {
      id: Uuid::from_u128(1000 + id),
      event_id: Uuid::nil(),
      kind,
      name: kind.label().into(),
      places,
      sort_order: kind.ceremony_order(),
    };
    Deliberation {
      event_id: Uuid::nil(),
      teams: team_scores(&inputs),
      nominations: BTreeMap::from([(Uuid::from_u128(3), vec![Nomination::Motivate])]),
      awards: vec![
        award(1, AwardKind::CoreValues, 2),
        award(2, AwardKind::Champions, 1),
        award(3, AwardKind::RobotPerformance, 2),
        award(4, AwardKind::InnovationProject, 1),
        award(5, AwardKind::RobotDesign, 2),
        award(6, AwardKind::Motivate, 1),
        award(7, AwardKind::CoachMentor, 1),
      ],
      winners: Vec::new(),
      advancement_slots: 1,
      advancing: Vec::new(),
      finalized: None,
    }
  }

  #[test]
  fn steps_follow_the_official_order() {
    let d = deliberation(6);
    let titles: Vec<String> = d.steps().into_iter().map(|s| d.step_title(s)).collect();
    assert_eq!(
      titles,
      [
        "Champion's",
        "Advancement",
        "Robot Performance 1st",
        "Robot Performance 2nd",
        "Core Values 1st",
        "Innovation Project",
        "Robot Design 1st",
        "Core Values 2nd",
        "Robot Design 2nd",
        "Coach/Mentor",
        "Motivate",
      ]
    );
  }

  #[test]
  fn one_judged_award_per_team() {
    let mut d = deliberation(6);
    let champions = Step::Award {
      award_id: Uuid::from_u128(1002),
      place: 1,
    };
    assert_eq!(d.top_candidate(champions), Some(Uuid::from_u128(1)));
    d.winners.push(AwardWinner {
      award_id: Uuid::from_u128(1002),
      team_id: Uuid::from_u128(1),
      place: 1,
      note: String::new(),
      assigned_by: "ja".into(),
    });
    let core_values = Step::Award {
      award_id: Uuid::from_u128(1001),
      place: 1,
    };
    assert_eq!(
      d.ineligible(core_values, Uuid::from_u128(1)).as_deref(),
      Some("Has Champion's")
    );
    assert_eq!(d.top_candidate(core_values), Some(Uuid::from_u128(2)));
    let robot_performance = Step::Award {
      award_id: Uuid::from_u128(1003),
      place: 1,
    };
    assert_eq!(
      d.top_candidate(robot_performance),
      Some(Uuid::from_u128(1)),
      "Robot Performance isn't limited"
    );
    let motivate = Step::Award {
      award_id: Uuid::from_u128(1006),
      place: 1,
    };
    assert_eq!(
      d.top_candidate(motivate),
      Some(Uuid::from_u128(3)),
      "only selected teams"
    );
    assert_eq!(
      d.ineligible(motivate, Uuid::from_u128(2)).as_deref(),
      Some("Not selected by the judges")
    );
  }
}
