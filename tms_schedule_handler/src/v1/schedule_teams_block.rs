use super::{V1Block, BLOCK_TEAMS};

pub struct ScheduleTeamT {
  pub team_number: String,
  pub name: String,
  pub affiliation: String,
}

pub struct ScheduleTeamsBlock {
  pub teams_count: usize,
  pub teams: Vec<ScheduleTeamT>,
}

impl V1Block for ScheduleTeamsBlock {
  type Output = ScheduleTeamsBlock;

  fn from_csv(csv: &str) -> Result<Self::Output, String> {
    let block_lines = match Self::get_block_lines(csv, BLOCK_TEAMS) {
      Ok(lines) => lines,
      Err(e) => return Err(e),
    };

    let mut n_teams: usize = 0;
    let mut teams: Vec<ScheduleTeamT> = vec![];

    for line in block_lines {
      let fields = line.split(",").collect::<Vec<&str>>();

      // Skip empty lines
      if fields.is_empty() || fields[0].trim().is_empty() {
        continue;
      }

      match fields[0] {
        "Number of Teams" => {
          let teams_str = fields.get(1).unwrap_or(&"0");
          n_teams = match teams_str.parse::<usize>() {
            Ok(n) => n,
            Err(e) => return Err(format!("Error parsing number of teams: {}", e)),
          }
        }
        _ => {
          // Use .get() with defaults to handle missing commas/fields
          let team_number = fields.get(0).unwrap_or(&"").to_string();
          let name = fields.get(1).unwrap_or(&"").to_string();
          let affiliation = fields.get(2).unwrap_or(&"").to_string();

          // Only add team if we have at least a team number
          if !team_number.trim().is_empty() {
            let team = ScheduleTeamT { team_number, name, affiliation };
            teams.push(team);
          }
        }
      }
    }

    Ok(ScheduleTeamsBlock { teams_count: n_teams, teams })
  }
}
