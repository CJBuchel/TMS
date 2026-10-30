use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord, Serialize, Deserialize)]
#[cfg_attr(feature = "sqlx", derive(sqlx::Type))]
#[cfg_attr(feature = "sqlx", sqlx(type_name = "role", rename_all = "snake_case"))]
#[cfg_attr(feature = "schema", derive(schemars::JsonSchema))]
#[serde(rename_all = "snake_case")]
pub enum Role {
  Admin,
  HeadReferee,
  Referee,
  JudgeAdvisor,
  Judge,
  Queuer,
  Emcee,
  Scorekeeper,
  Display,
}

impl Role {
  pub const ALL: [Role; 9] = [
    Role::Admin,
    Role::HeadReferee,
    Role::Referee,
    Role::JudgeAdvisor,
    Role::Judge,
    Role::Queuer,
    Role::Emcee,
    Role::Scorekeeper,
    Role::Display,
  ];

  /// Whether holding `self` grants what `required` grants.
  /// Admin grants everything. Head referee grants referee and queuer. Judge advisor grants judge.
  /// Every role grants display, which is read-only public data.
  pub fn satisfies(self, required: Role) -> bool {
    if self == required || required == Role::Display {
      return true;
    }
    match self {
      Role::Admin => true,
      Role::HeadReferee => matches!(required, Role::Referee | Role::Queuer),
      Role::JudgeAdvisor => required == Role::Judge,
      _ => false,
    }
  }

  pub fn label(self) -> &'static str {
    match self {
      Role::Admin => "Admin",
      Role::HeadReferee => "Head Referee",
      Role::Referee => "Referee",
      Role::JudgeAdvisor => "Judge Advisor",
      Role::Judge => "Judge",
      Role::Queuer => "Queuer",
      Role::Emcee => "Emcee",
      Role::Scorekeeper => "Scorekeeper",
      Role::Display => "Display",
    }
  }

  /// Prefix printed at the start of an access key, so an offline device can tell the role before the server is reachable.
  pub fn key_prefix(self) -> &'static str {
    match self {
      Role::Admin => "ADM",
      Role::HeadReferee => "HR",
      Role::Referee => "REF",
      Role::JudgeAdvisor => "JA",
      Role::Judge => "JDG",
      Role::Queuer => "QUE",
      Role::Emcee => "MC",
      Role::Scorekeeper => "SK",
      Role::Display => "DSP",
    }
  }

  pub fn from_key_prefix(prefix: &str) -> Option<Role> {
    Role::ALL.into_iter().find(|r| r.key_prefix() == prefix)
  }
}

pub fn has_role(roles: &[Role], required: Role) -> bool {
  roles.iter().any(|r| r.satisfies(required))
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn admin_satisfies_everything() {
    for r in Role::ALL {
      assert!(Role::Admin.satisfies(r));
    }
  }

  #[test]
  fn inheritance() {
    assert!(Role::HeadReferee.satisfies(Role::Referee));
    assert!(Role::HeadReferee.satisfies(Role::Queuer));
    assert!(!Role::HeadReferee.satisfies(Role::Judge));
    assert!(Role::JudgeAdvisor.satisfies(Role::Judge));
    assert!(!Role::Judge.satisfies(Role::JudgeAdvisor));
    assert!(!Role::Referee.satisfies(Role::HeadReferee));
    assert!(Role::Referee.satisfies(Role::Display));
  }

  #[test]
  fn key_prefixes_round_trip_and_are_unique() {
    for r in Role::ALL {
      assert_eq!(Role::from_key_prefix(r.key_prefix()), Some(r));
    }
  }
}
