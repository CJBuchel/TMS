//! BIOGLOW (Founders Edition), 2026-27. Wording follows the official software scoresheet, and points follow
//! the official Excel scorer.

use crate::{ChoiceOption, DefaultAnswer, Field, FieldKind, Mission, Scoring, Season};

pub static BIOGLOW_FOUNDERS: Season = Season {
  id: "bioglow_founders",
  name: "BIOGLOW, Founders Edition (2026-27)",
  schema_version: 1,
  missions: MISSIONS,
  max_score: 530,
  rubrics: crate::rubric::CHALLENGE_RUBRICS,
  score,
};

const NO: Option<DefaultAnswer> = Some(DefaultAnswer::Bool(false));
const YES: Option<DefaultAnswer> = Some(DefaultAnswer::Bool(true));
const ZERO: Option<DefaultAnswer> = Some(DefaultAnswer::Count(0));

const fn bool_field(id: &'static str, label: &'static str, default: Option<DefaultAnswer>) -> Field {
  Field {
    id,
    label,
    kind: FieldKind::Bool,
    default,
    requires: None,
  }
}

const fn bonus(id: &'static str, label: &'static str, requires: &'static str, default: Option<DefaultAnswer>) -> Field {
  Field {
    id,
    label,
    kind: FieldKind::Bool,
    default,
    requires: Some(requires),
  }
}

const fn count(id: &'static str, label: &'static str, max: u8) -> Field {
  Field {
    id,
    label,
    kind: FieldKind::Count { max },
    default: ZERO,
    requires: None,
  }
}

const fn mission(
  id: &'static str,
  name: &'static str,
  image: &'static str,
  no_equipment_constraint: bool,
  fields: &'static [Field],
) -> Mission {
  Mission {
    id,
    name,
    image: Some(image),
    no_equipment_constraint,
    fields,
  }
}

const ROOT_OPTIONS: &[ChoiceOption] = &[
  ChoiceOption { key: "no", label: "No" },
  ChoiceOption {
    key: "partially",
    label: "Partially",
  },
  ChoiceOption {
    key: "completely",
    label: "Completely",
  },
];

const DOCK_OPTIONS: &[ChoiceOption] = &[
  ChoiceOption {
    key: "mine",
    label: "Mine",
  },
  ChoiceOption {
    key: "city",
    label: "City",
  },
  ChoiceOption {
    key: "farm",
    label: "Farm",
  },
];

static MISSIONS: &[Mission] = &[
  mission(
    "m00",
    "Equipment inspection",
    "missions/bioglow/fo_m00.png",
    false,
    &[bool_field(
      "m00a",
      "(Prematch) The robot and all equipment fit completely in one launch area and under the height limit",
      NO,
    )],
  ),
  mission(
    "m01",
    "M01 Drone survey",
    "missions/bioglow/fo_m01.png",
    true,
    &[
      bool_field("m01a", "The drone is no longer touching the mat", NO),
      bonus(
        "m01b",
        "Bonus: and the LiDAR map is completely flipped over, with the scan marker at least partly in the survey area",
        "m01a",
        NO,
      ),
    ],
  ),
  mission(
    "m02",
    "M02 Exploding seeds",
    "missions/bioglow/fo_m02.png",
    false,
    &[count("m02a", "Number of seeds no longer touching the stalk", 3)],
  ),
  mission(
    "m03",
    "M03 Flip the rock",
    "missions/bioglow/fo_m03.png",
    false,
    &[
      bool_field("m03a", "The research flag is down", NO),
      bonus(
        "m03b",
        "Bonus: and the rock has been returned to its original starting position",
        "m03a",
        NO,
      ),
    ],
  ),
  mission(
    "m04",
    "M04 Lucky leaves",
    "missions/bioglow/fo_m04.png",
    true,
    &[
      count("m04a", "Number of leaves no longer touching the nest", 2),
      bool_field("m04b", "The katydid is at least partly in the leaf habitat", YES),
      bonus(
        "m04c",
        "Bonus: and the katydid is in its original position and remained at least partly in the leaf habitat \
         throughout the match",
        "m04b",
        YES,
      ),
    ],
  ),
  mission(
    "m05",
    "M05 Reaching roots",
    "missions/bioglow/fo_m05.png",
    true,
    &[Field {
      id: "m05a",
      label: "The plant root is extended",
      kind: FieldKind::Choice { options: ROOT_OPTIONS },
      default: Some(DefaultAnswer::Choice("no")),
      requires: None,
    }],
  ),
  mission(
    "m06",
    "M06 Leafcutter frenzy",
    "missions/bioglow/fo_m06.png",
    false,
    &[
      bool_field("m06a", "The ant is touching the nest", NO),
      Field {
        requires: Some("m06a"),
        ..count("m06b", "Number of leaf fragments contained within the nest", 4)
      },
    ],
  ),
  mission(
    "m07",
    "M07 Humongous fungus",
    "missions/bioglow/fo_m07.png",
    true,
    &[
      bool_field("m07a", "The mycelium is completely extended", NO),
      Field {
        requires: Some("m07a"),
        ..count(
          "m07b",
          "Bonus: number of connections formed between one team's extended mycelium and the opposing team's fully \
           extended plant root",
          2,
        )
      },
    ],
  ),
  mission(
    "m08",
    "M08 Tangled",
    "missions/bioglow/fo_m08.png",
    false,
    &[bool_field("m08a", "The vine is touching the mat", NO)],
  ),
  mission(
    "m09",
    "M09 Research platform",
    "missions/bioglow/fo_m09.png",
    true,
    &[
      bool_field("m09a", "The research platform is raised", NO),
      bool_field("m09b", "The camera trap is deployed", NO),
      bool_field("m09c", "The seed is no longer touching the tree", NO),
    ],
  ),
  mission(
    "m10",
    "M10 Fragile microhabitats",
    "missions/bioglow/fo_m10.png",
    true,
    &[
      bool_field("m10a", "The spider habitat is in its original starting position", YES),
      bool_field("m10b", "The snail habitat is in its original starting position", YES),
    ],
  ),
  mission(
    "m11",
    "M11 Window to the past",
    "missions/bioglow/fo_m11.png",
    false,
    &[bool_field("m11a", "The root cover is down, touching the mat", NO)],
  ),
  mission(
    "m12",
    "M12 Forest elder",
    "missions/bioglow/fo_m12.png",
    true,
    &[
      bool_field("m12a", "The cane is completely raised, touching the tree", NO),
      bool_field("m12b", "The support tie is around the post", NO),
    ],
  ),
  mission(
    "m13",
    "M13 Keystone species",
    "missions/bioglow/fo_m13.png",
    false,
    &[bool_field(
      "m13a",
      "Your keystone species is on the restoration platform, and the young trees are raised",
      NO,
    )],
  ),
  mission(
    "m14",
    "M14 Seeds of renewal",
    "missions/bioglow/fo_m14.png",
    false,
    &[
      count("m14a", "Number of seeds contained within the replantation station", 4),
      count("m14b", "Bonus: and touching the mat", 4),
    ],
  ),
  mission(
    "m15",
    "M15 Biocentric architecture",
    "missions/bioglow/fo_m15.png",
    true,
    &[
      bool_field("m15a", "The nesting canopy is raised", NO),
      bool_field("m15b", "The garden skylight is completely in", NO),
      bool_field("m15c", "The compost hatch is completely opened, touching the mat", NO),
      Field {
        id: "m15d",
        label: "Dock location",
        kind: FieldKind::Choice { options: DOCK_OPTIONS },
        default: None,
        requires: None,
      },
    ],
  ),
  mission(
    "m16",
    "Precision tokens",
    "missions/bioglow/fo_m16.png",
    false,
    &[Field {
      default: Some(DefaultAnswer::Count(6)),
      ..count("m16a", "Number of precision tokens remaining", 6)
    }],
  ),
];

fn points(yes: bool, points: u16) -> u16 {
  if yes { points } else { 0 }
}

fn score(s: &mut Scoring) {
  s.add("m00", points(s.yes("m00a"), 20));
  s.add(
    "m01",
    points(s.yes("m01a"), 20) + points(s.yes("m01a") && s.yes("m01b"), 10),
  );
  s.add("m02", u16::from(s.count("m02a")) * 10);
  s.add(
    "m03",
    points(s.yes("m03a"), 20) + points(s.yes("m03a") && s.yes("m03b"), 10),
  );

  let leaves = s.count("m04a");
  let in_habitat = s.yes("m04b");
  s.add(
    "m04",
    points(in_habitat && leaves >= 1, 10) + points(in_habitat && leaves == 2 && s.yes("m04c"), 20),
  );

  let root = match s.choice("m05a") {
    Some("partially") => 10,
    Some("completely") => 20,
    _ => 0,
  };
  s.add("m05", root);
  s.add("m06", points(s.yes("m06a"), u16::from(s.count("m06b")) * 10));
  s.add("m07", points(s.yes("m07a"), 20 + u16::from(s.count("m07b")) * 10));
  s.add("m08", points(s.yes("m08a"), 30));
  s.add(
    "m09",
    points(s.yes("m09a"), 10) + points(s.yes("m09b"), 10) + points(s.yes("m09c"), 10),
  );
  s.add("m10", points(s.yes("m10a"), 10) + points(s.yes("m10b"), 10));
  s.add("m11", points(s.yes("m11a"), 20));
  s.add("m12", points(s.yes("m12a"), 20) + points(s.yes("m12b"), 10));
  s.add("m13", points(s.yes("m13a"), 30));

  let planted = s.count("m14a");
  let rooted = s.count("m14b");
  s.add("m14", u16::from(planted) * 5 + u16::from(rooted.min(planted)) * 5);
  if rooted > planted {
    s.error(
      "m14b",
      "Seeds touching the mat can't be more than the seeds in the replantation station.",
    );
  }
  let released = s.count("m02a") + u8::from(s.yes("m09c"));
  if planted > released {
    s.warn(
      "m14a",
      &format!("Only {released} seeds were released in M02 and M09, but {planted} are in the replantation station."),
    );
  }

  let dock_bonus = match s.choice("m15d") {
    Some("mine") => s.yes("m15a"),
    Some("city") => s.yes("m15b"),
    Some("farm") => s.yes("m15c"),
    _ => false,
  };
  s.add(
    "m15",
    points(s.yes("m15a"), 10) + points(s.yes("m15b"), 10) + points(s.yes("m15c"), 10) + points(dock_bonus, 10),
  );

  let tokens = match s.count("m16a") {
    1 => 10,
    2 => 15,
    3 => 25,
    4 => 35,
    5 | 6 => 50,
    _ => 0,
  };
  s.add("m16", tokens);
}

#[cfg(test)]
mod tests {
  use super::*;
  use crate::{Answer, Answers, Severity};

  fn sheet(changes: &[(&str, Answer)]) -> Answers {
    let mut answers = BIOGLOW_FOUNDERS.defaults();
    answers.insert("m15d".into(), Answer::Choice("mine".into()));
    for (id, answer) in changes {
      answers.insert((*id).into(), answer.clone());
    }
    answers
  }

  fn yes(id: &str) -> (&str, Answer) {
    (id, Answer::Bool(true))
  }

  fn no(id: &str) -> (&str, Answer) {
    (id, Answer::Bool(false))
  }

  fn n(id: &str, value: u8) -> (&str, Answer) {
    (id, Answer::Count(value))
  }

  fn choice<'a>(id: &'a str, key: &str) -> (&'a str, Answer) {
    (id, Answer::Choice(key.into()))
  }

  fn total(changes: &[(&str, Answer)]) -> u16 {
    let result = BIOGLOW_FOUNDERS.score(&sheet(changes));
    assert!(!result.has_errors(), "{:?}", result.issues);
    result.total
  }

  #[test]
  fn a_new_sheet_needs_the_dock_and_otherwise_scores_70() {
    let result = BIOGLOW_FOUNDERS.score(&BIOGLOW_FOUNDERS.defaults());
    assert_eq!(result.issues.len(), 1);
    assert_eq!(result.issues[0].field, "m15d");
    assert_eq!(total(&[]), 70, "both habitats (20) and six precision tokens (50)");
  }

  #[test]
  fn maximum_score_is_reachable() {
    let best = [
      yes("m00a"),
      yes("m01a"),
      yes("m01b"),
      n("m02a", 3),
      yes("m03a"),
      yes("m03b"),
      n("m04a", 2),
      choice("m05a", "completely"),
      yes("m06a"),
      n("m06b", 4),
      yes("m07a"),
      n("m07b", 2),
      yes("m08a"),
      yes("m09a"),
      yes("m09b"),
      yes("m09c"),
      yes("m11a"),
      yes("m12a"),
      yes("m12b"),
      yes("m13a"),
      n("m14a", 4),
      n("m14b", 4),
      yes("m15a"),
      yes("m15b"),
      yes("m15c"),
    ];
    let result = BIOGLOW_FOUNDERS.score(&sheet(&best));
    assert_eq!(result.issues, vec![]);
    assert_eq!(result.total, BIOGLOW_FOUNDERS.max_score);
  }

  #[test]
  fn lucky_leaves() {
    assert_eq!(total(&[n("m04a", 1)]), 80);
    assert_eq!(total(&[n("m04a", 2)]), 100, "two leaves with the bonus");
    assert_eq!(
      total(&[n("m04a", 2), no("m04c")]),
      80,
      "two leaves without the bonus is still valid"
    );
    assert_eq!(
      total(&[n("m04a", 2), no("m04b"), no("m04c")]),
      70,
      "katydid out of the habitat"
    );
  }

  #[test]
  fn precision_tokens() {
    let expected = [0, 10, 15, 25, 35, 50, 50];
    for (tokens, points) in expected.into_iter().enumerate() {
      assert_eq!(total(&[n("m16a", u8::try_from(tokens).unwrap())]), 20 + points);
    }
  }

  #[test]
  fn dock_bonus_needs_its_matching_feature() {
    assert_eq!(total(&[yes("m15a"), choice("m15d", "mine")]), 90);
    assert_eq!(total(&[yes("m15a"), choice("m15d", "city")]), 80);
    assert_eq!(total(&[yes("m15c"), choice("m15d", "farm")]), 90);
  }

  #[test]
  fn seeds_of_renewal() {
    assert_eq!(total(&[n("m02a", 3), n("m14a", 3), n("m14b", 2)]), 70 + 30 + 15 + 10);
    let too_many_rooted = BIOGLOW_FOUNDERS.score(&sheet(&[n("m02a", 3), n("m14a", 1), n("m14b", 2)]));
    assert!(too_many_rooted.has_errors());
    assert_eq!(
      too_many_rooted.total,
      70 + 30 + 5 + 5,
      "the official scorer caps the bonus"
    );

    let unreleased = BIOGLOW_FOUNDERS.score(&sheet(&[n("m14a", 2)]));
    assert!(!unreleased.has_errors(), "a warning only");
    assert_eq!(unreleased.issues[0].severity, Severity::Warning);
    assert_eq!(unreleased.total, 80);
  }

  #[test]
  fn every_bonus_reports_a_missing_prerequisite() {
    for field in BIOGLOW_FOUNDERS.fields().filter(|f| f.requires.is_some()) {
      let prerequisite = field.requires.unwrap();
      let value = match field.kind {
        crate::FieldKind::Bool => Answer::Bool(true),
        crate::FieldKind::Count { max } => Answer::Count(max),
        crate::FieldKind::Choice { .. } => unreachable!(),
      };
      let result = BIOGLOW_FOUNDERS.score(&sheet(&[no(prerequisite), (field.id, value)]));
      assert!(
        result.issues_for(field.id).next().is_some(),
        "{} without {prerequisite}",
        field.id
      );
    }
  }

  #[test]
  fn setting_a_prerequisite_to_no_resets_its_bonus() {
    let mut answers = sheet(&[yes("m07a"), n("m07b", 2)]);
    BIOGLOW_FOUNDERS.set(&mut answers, "m07a", Answer::Bool(false));
    assert_eq!(answers["m07b"], Answer::Count(0));
    BIOGLOW_FOUNDERS.set(&mut answers, "m04b", Answer::Bool(false));
    assert_eq!(answers["m04c"], Answer::Bool(false));
    assert!(!BIOGLOW_FOUNDERS.score(&answers).has_errors());
  }

  #[test]
  fn malformed_answers_are_errors() {
    let result = BIOGLOW_FOUNDERS.score(&sheet(&[
      n("m02a", 4),
      choice("m05a", "sideways"),
      n("m08a", 1),
      yes("m99"),
    ]));
    let fields: Vec<_> = result.issues.iter().map(|i| i.field.as_str()).collect();
    assert_eq!(fields, ["m99", "m02a", "m05a", "m08a"]);
  }

  /// The official Excel scorer's formulas, transcribed cell by cell. Each input is the 1-based index of the
  /// chosen option in column F, rows 4 to 34.
  fn excel(f: &[u16; 31]) -> u16 {
    let f = |row: usize| f[row - 4];
    let h = [
      (f(4) - 1) * 20,
      (f(5) - 1) * 20,
      if f(5) > 1 { (f(6) - 1) * 10 } else { 0 },
      (f(7) - 1) * 10,
      (f(8) - 1) * 20,
      if f(8) > 1 { (f(9) - 1) * 10 } else { 0 },
      if f(11) > 1 && f(10) > 1 { 10 } else { 0 },
      if f(10) > 2 && f(11) > 1 { (f(12) - 1) * 20 } else { 0 },
      (f(13) - 1) * 10,
      if f(14) > 1 { (f(15) - 1) * 10 } else { 0 },
      (f(16) - 1) * 20,
      if f(16) > 1 { (f(17) - 1) * 10 } else { 0 },
      (f(18) - 1) * 30,
      (f(19) - 1) * 10,
      (f(20) - 1) * 10,
      (f(21) - 1) * 10,
      (f(22) - 1) * 10,
      (f(23) - 1) * 10,
      (f(24) - 1) * 20,
      (f(25) - 1) * 20,
      (f(26) - 1) * 10,
      (f(27) - 1) * 30,
      (f(28) - 1) * 5,
      if f(29) > f(28) {
        (f(28) - 1) * 5
      } else {
        (f(29) - 1) * 5
      },
      (f(30) - 1) * 10,
      (f(31) - 1) * 10,
      (f(32) - 1) * 10,
      if (f(30) > 1 && f(33) == 1) || (f(31) > 1 && f(33) == 2) || (f(32) > 1 && f(33) == 3) {
        10
      } else {
        0
      },
      match f(34) {
        6 | 7 => 50,
        5 => 35,
        4 => 25,
        3 => 15,
        2 => 10,
        _ => 0,
      },
    ];
    h.iter().sum()
  }

  /// Field order matching the scorer's rows 4 to 34.
  const ROWS: [&str; 31] = [
    "m00a", "m01a", "m01b", "m02a", "m03a", "m03b", "m04a", "m04b", "m04c", "m05a", "m06a", "m06b", "m07a", "m07b",
    "m08a", "m09a", "m09b", "m09c", "m10a", "m10b", "m11a", "m12a", "m12b", "m13a", "m14a", "m14b", "m15a", "m15b",
    "m15c", "m15d", "m16a",
  ];

  #[test]
  fn matches_the_official_excel_scorer() {
    let mut seed: u64 = 0x5eed;
    let mut next = |options: u16| {
      seed = seed
        .wrapping_mul(6_364_136_223_846_793_005)
        .wrapping_add(1_442_695_040_888_963_407);
      u16::try_from((seed >> 33) % u64::from(options)).unwrap() + 1
    };
    for _ in 0..20_000 {
      let mut f = [1u16; 31];
      let mut answers = Answers::new();
      for (i, id) in ROWS.iter().enumerate() {
        let field = BIOGLOW_FOUNDERS.field(id).unwrap();
        let answer = match field.kind {
          crate::FieldKind::Bool => {
            f[i] = next(2);
            Answer::Bool(f[i] == 2)
          }
          crate::FieldKind::Count { max } => {
            f[i] = next(u16::from(max) + 1);
            Answer::Count(u8::try_from(f[i] - 1).unwrap())
          }
          crate::FieldKind::Choice { options } => {
            f[i] = next(u16::try_from(options.len()).unwrap());
            Answer::Choice(options[usize::from(f[i] - 1)].key.into())
          }
        };
        answers.insert((*id).into(), answer);
      }
      assert_eq!(BIOGLOW_FOUNDERS.score(&answers).total, excel(&f), "{answers:?}");
    }
  }
}
