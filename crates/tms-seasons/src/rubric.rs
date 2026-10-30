//! Judging rubrics: Innovation Project and Robot Design. Each row is scored 1 (Beginning) to 4 (Exceeds), and an
//! Exceeds needs a comment. Rows marked `core_values` also count toward Core Values. Wording follows the official
//! BIOGLOW rubrics, which keep the structure used since 2024-25.

use std::collections::BTreeMap;

use crate::{Issue, Severity};

pub struct Rubric {
  /// `ip` or `rd`.
  pub id: &'static str,
  pub name: &'static str,
  pub sections: &'static [RubricSection],
}

/// A heading on the sheet, such as "IDENTIFY", with its rows.
pub struct RubricSection {
  pub name: &'static str,
  pub description: &'static str,
  pub rows: &'static [RubricRow],
}

pub struct RubricRow {
  pub id: &'static str,
  /// Short name for tables, such as "Research".
  pub label: &'static str,
  /// What Beginning, Developing and Accomplished look like. Exceeds is the judges' own comment.
  pub levels: [&'static str; 3],
  pub core_values: bool,
}

pub const LEVELS: [&str; 4] = ["Beginning", "Developing", "Accomplished", "Exceeds"];

impl Rubric {
  pub fn rows(&self) -> impl Iterator<Item = &'static RubricRow> {
    self.sections.iter().flat_map(|s| s.rows.iter())
  }
}

/// Totals of one team's rubrics: each area's sum, and the Core Values rows from both.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct RubricTotals {
  pub innovation_project: u16,
  pub robot_design: u16,
  pub core_values_rows: u16,
}

pub fn totals(rubrics: &[Rubric], scores: &BTreeMap<String, u8>) -> RubricTotals {
  let mut t = RubricTotals::default();
  for rubric in rubrics {
    for row in rubric.rows() {
      let score = u16::from(scores.get(row.id).copied().unwrap_or(0));
      match rubric.id {
        "ip" => t.innovation_project += score,
        "rd" => t.robot_design += score,
        _ => {}
      }
      if row.core_values {
        t.core_values_rows += score;
      }
    }
  }
  t
}

/// Every problem with a filled-in rubric: rows not scored, scores out of range, Exceeds without a comment.
pub fn check(rubrics: &[Rubric], scores: &BTreeMap<String, u8>, comments: &BTreeMap<String, String>) -> Vec<Issue> {
  let mut issues = Vec::new();
  let mut error = |field: &str, message: String| {
    issues.push(Issue {
      field: field.to_owned(),
      message,
      severity: Severity::Error,
    });
  };
  let known: Vec<&str> = rubrics.iter().flat_map(Rubric::rows).map(|r| r.id).collect();
  for id in scores.keys() {
    if !known.contains(&id.as_str()) {
      error(id, "This row is not on this season's rubrics.".into());
    }
  }
  for rubric in rubrics {
    for row in rubric.rows() {
      match scores.get(row.id) {
        None => error(row.id, format!("{}: choose a level.", row.label)),
        Some(0 | 5..) => error(row.id, format!("{}: the level is 1 to 4.", row.label)),
        Some(4) if comments.get(row.id).is_none_or(|c| c.trim().is_empty()) => {
          error(row.id, format!("{}: say how the team exceeded.", row.label));
        }
        Some(_) => {}
      }
    }
  }
  issues
}

const fn row(id: &'static str, label: &'static str, levels: [&'static str; 3], core_values: bool) -> RubricRow {
  RubricRow {
    id,
    label,
    levels,
    core_values,
  }
}

/// The FIRST LEGO League Challenge rubrics as printed for BIOGLOW.
pub static CHALLENGE_RUBRICS: &[Rubric] = &[
  Rubric {
    id: "ip",
    name: "Innovation Project",
    sections: &[
      RubricSection {
        name: "Identify",
        description: "Team had a clearly defined problem that was well researched.",
        rows: &[
          row(
            "ip_identify_define",
            "Problem",
            [
              "Unclear definition of the problem",
              "Partially clear definition of the problem",
              "Clear definition of the problem",
            ],
            false,
          ),
          row(
            "ip_identify_research",
            "Research",
            [
              "Minimal evidence of research",
              "Partial evidence of research from one or more sources",
              "Clear, detailed research from a variety of sources",
            ],
            true,
          ),
        ],
      },
      RubricSection {
        name: "Design",
        description: "Team worked together while creating a project plan and developing their ideas.",
        rows: &[
          row(
            "ip_design_plan",
            "Project plan",
            [
              "Minimal evidence of an effective project plan",
              "Partial evidence of an effective project plan",
              "Clear evidence of an effective project plan",
            ],
            false,
          ),
          row(
            "ip_design_teamwork",
            "Teamwork",
            [
              "Minimal evidence that development process involved all team members",
              "Partial evidence that development process involved all team members",
              "Clear evidence that development process involved all team members",
            ],
            true,
          ),
        ],
      },
      RubricSection {
        name: "Create",
        description: "Team developed an original idea or built on an existing one with a prototype model/drawing to \
                      represent their solution.",
        rows: &[
          row(
            "ip_create_innovation",
            "Innovation",
            [
              "Minimal explanation of innovation in solution",
              "Simple explanation of innovation in solution",
              "Detailed explanation of innovation in solution",
            ],
            true,
          ),
          row(
            "ip_create_model",
            "Model",
            [
              "Unclear model/drawing that represents the solution",
              "Simple model/drawing that represents the solution",
              "Detailed model/drawing that represents the solution",
            ],
            false,
          ),
        ],
      },
      RubricSection {
        name: "Iterate",
        description: "Team shared their ideas with others, collected feedback, and included improvements to their \
                      solution.",
        rows: &[
          row(
            "ip_iterate_sharing",
            "Sharing",
            [
              "Minimal sharing of their solution with others",
              "Solution shared with at least one person/group",
              "Solution shared with multiple people/groups",
            ],
            false,
          ),
          row(
            "ip_iterate_improvement",
            "Improvement",
            [
              "Minimal evidence of improvements based on feedback",
              "Partial evidence of improvements based on feedback",
              "Clear evidence of improvements based on feedback",
            ],
            false,
          ),
        ],
      },
      RubricSection {
        name: "Communicate",
        description: "Team shared an effective presentation of their solution, its impact on others, and celebrated \
                      their team's progress.",
        rows: &[
          row(
            "ip_communicate_impact",
            "Impact",
            [
              "Unclear explanation of the solution and its potential impact on others",
              "Partially clear explanation of solution and its potential impact on others",
              "Clear explanation of solution and its potential impact on others",
            ],
            true,
          ),
          row(
            "ip_communicate_fun",
            "Pride and enthusiasm",
            [
              "Presentation shows minimal pride or enthusiasm for their work",
              "Presentation shows partial pride or enthusiasm for their work",
              "Presentation clearly shows pride or enthusiasm for their work",
            ],
            true,
          ),
        ],
      },
    ],
  },
  Rubric {
    id: "rd",
    name: "Robot Design",
    sections: &[
      RubricSection {
        name: "Identify",
        description: "Team determined which missions to attempt, explored building and coding resources, and sought \
                      guidance as needed.",
        rows: &[
          row(
            "rd_identify_strategy",
            "Mission strategy",
            [
              "Minimal evidence of mission strategy",
              "Partial evidence of mission strategy",
              "Clear evidence of mission strategy",
            ],
            false,
          ),
          row(
            "rd_identify_research",
            "Resources",
            [
              "Minimal use of building or coding resources",
              "Some use of building or coding resources",
              "Clear use of building or coding resources to support their mission strategy",
            ],
            true,
          ),
        ],
      },
      RubricSection {
        name: "Design",
        description: "Team members worked collaboratively on their designs and developed the building and coding \
                      skills needed.",
        rows: &[
          row(
            "rd_design_ideas",
            "Ideas",
            [
              "Minimal evidence that all team members contributed ideas",
              "Partial evidence that all team members contributed ideas",
              "Clear evidence that all team members contributed ideas",
            ],
            true,
          ),
          row(
            "rd_design_skills",
            "Building and coding skills",
            [
              "Minimal evidence of building and coding skills in all team members",
              "Partial evidence of building and coding skills in all team members",
              "Clear evidence of building and coding skills in all team members",
            ],
            false,
          ),
        ],
      },
      RubricSection {
        name: "Create",
        description: "Team developed original designs or improved on existing ones according to their mission \
                      strategy.",
        rows: &[
          row(
            "rd_create_attachments",
            "Attachments",
            [
              "Unclear explanation of attachments and their purpose",
              "Simple explanation of attachments and their purpose",
              "Clear explanation of innovative attachments and their purpose",
            ],
            false,
          ),
          row(
            "rd_create_code",
            "Code and sensors",
            [
              "Unclear explanation of code and/or sensor use",
              "Simple explanation of code and/or sensor use",
              "Clear explanation of innovative code and/or sensor use",
            ],
            false,
          ),
        ],
      },
      RubricSection {
        name: "Iterate",
        description: "Team repeatedly tested their robot and code to identify areas for improvement and incorporated \
                      the findings into their solutions.",
        rows: &[
          row(
            "rd_iterate_testing",
            "Testing",
            [
              "Minimal evidence of testing their robot and code",
              "Partial evidence of testing their robot and code",
              "Clear evidence of repeated testing of their robot and code",
            ],
            false,
          ),
          row(
            "rd_iterate_improvements",
            "Improvements",
            [
              "Minimal evidence of improvements based on testing",
              "Partial evidence of improvements based on testing",
              "Clear evidence of improvements based on testing",
            ],
            true,
          ),
        ],
      },
      RubricSection {
        name: "Communicate",
        description: "Team effectively explained what they learned from the robot design process and celebrated \
                      their progress.",
        rows: &[
          row(
            "rd_communicate_impact",
            "Lessons learned",
            [
              "Unclear explanation of process and lessons learned",
              "Simple explanation of process and lessons learned",
              "Detailed explanation of process and lessons learned",
            ],
            true,
          ),
          row(
            "rd_communicate_fun",
            "Pride and enthusiasm",
            [
              "Team shows minimal pride or enthusiasm for their work",
              "Team shows partial pride or enthusiasm for their work",
              "Team clearly shows pride or enthusiasm for their work",
            ],
            true,
          ),
        ],
      },
    ],
  },
];

#[cfg(test)]
mod tests {
  use super::*;

  fn all(level: u8) -> BTreeMap<String, u8> {
    CHALLENGE_RUBRICS
      .iter()
      .flat_map(Rubric::rows)
      .map(|r| (r.id.to_owned(), level))
      .collect()
  }

  #[test]
  fn ten_rows_each_five_count_for_core_values() {
    for rubric in CHALLENGE_RUBRICS {
      assert_eq!(rubric.rows().count(), 10, "{}", rubric.id);
      assert_eq!(rubric.rows().filter(|r| r.core_values).count(), 5, "{}", rubric.id);
    }
  }

  #[test]
  fn totals_by_area() {
    let t = totals(CHALLENGE_RUBRICS, &all(3));
    assert_eq!(
      t,
      RubricTotals {
        innovation_project: 30,
        robot_design: 30,
        core_values_rows: 30
      }
    );
    assert_eq!(totals(CHALLENGE_RUBRICS, &all(4)).core_values_rows, 40);
  }

  #[test]
  fn exceeds_needs_a_comment_and_every_row_a_level() {
    let mut scores = all(3);
    scores.insert("ip_create_model".into(), 4);
    scores.remove("rd_iterate_testing");
    let issues = check(CHALLENGE_RUBRICS, &scores, &BTreeMap::new());
    let fields: Vec<&str> = issues.iter().map(|i| i.field.as_str()).collect();
    assert_eq!(fields, ["ip_create_model", "rd_iterate_testing"]);
    let comments = BTreeMap::from([(
      "ip_create_model".to_owned(),
      "Working prototype tested with a park ranger".to_owned(),
    )]);
    scores.insert("rd_iterate_testing".into(), 2);
    assert_eq!(check(CHALLENGE_RUBRICS, &scores, &comments), vec![]);
  }
}
