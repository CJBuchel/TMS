use database::Record;
use serde::{Deserialize, Serialize};

#[derive(Clone, Serialize, Deserialize)]
pub struct Team {
  pub team_number: String,
  pub name: String,
  pub affiliation: String,
}

impl Default for Team {
  fn default() -> Self {
    Self {
      team_number: "".to_string(),
      name: "".to_string(),
      affiliation: "".to_string(),
    }
  }
}

impl Record for Team {
  fn table_name() -> &'static str {
    "team"
  }

  fn secondary_indexes(&self) -> Vec<String> {
    vec![self.team_number.clone(), self.name.clone(), self.affiliation.clone()]
  }
}
