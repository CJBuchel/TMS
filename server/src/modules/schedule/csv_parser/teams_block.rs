use crate::modules::schedule::csv_parser::block::{BLOCK_TEAMS, Block};

#[derive(Debug, Clone)]
pub struct ScheduleTeamT {
  pub team_number: String,
  pub name: String,
  pub affiliation: String,
}

#[derive(Debug, Clone)]
pub struct ScheduledTeams {
  pub teams: Vec<ScheduleTeamT>,
}

impl Block for ScheduledTeams {
  type Output = ScheduledTeams;

  fn from_csv(csv: &str) -> Result<Self::Output, String> {
    let block_lines = Self::get_block_lines(csv, BLOCK_TEAMS)?;

    let mut teams: Vec<ScheduleTeamT> = vec![];

    for line in block_lines {
      let fields = line.split(',').collect::<Vec<&str>>();

      // Skip empty lines
      if fields.is_empty() || fields[0].trim().is_empty() {
        continue;
      }

      if fields[0] != "Number of Teams" {
        // Use .get() with defaults to handle missing commas/fields
        let team_number = fields.first().unwrap_or(&"").to_string();
        let name = fields.get(1).unwrap_or(&"").to_string();
        let affiliation = fields.get(2).unwrap_or(&"").to_string();

        // Only add team if we have at least a team number
        if !team_number.trim().is_empty() {
          let team = ScheduleTeamT { team_number, name, affiliation };
          teams.push(team);
        }
      }
    }

    Ok(ScheduledTeams { teams })
  }
}
