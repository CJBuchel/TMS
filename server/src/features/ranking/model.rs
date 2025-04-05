use database::Record;
use serde::{Deserialize, Serialize};

#[derive(Clone, Serialize, Deserialize)]
pub struct Ranking {
  pub team_id: String,
  pub rank: u32,
}

impl Default for Ranking {
  fn default() -> Self {
    Self {
      team_id: "".to_string(),
      rank: 0,
    }
  }
}

impl Record for Ranking {
  fn table_name() -> &'static str {
    "ranking"
  }

  fn secondary_indexes(&self) -> Vec<String> {
    vec![self.team_id.clone(), self.rank.to_string()]
  }
}
