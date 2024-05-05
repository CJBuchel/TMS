
use super::{V1Block, BLOCK_TEAMS};

pub struct ScheduleTeamT {
  pub number: String,
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

      match fields[0] {
        "Number of Teams" => {
          n_teams = match fields[1].parse::<usize>() {
            Ok(n) => n,
            Err(e) => return Err(format!("Error parsing number of teams: {}", e)),
          }
        },
        _ => {
          let team = ScheduleTeamT {
            number: fields[0].to_string(),
            name: fields[1].to_string(),
            affiliation: fields[2].to_string(),
          };
          teams.push(team);
        },
      }
    }

    Ok(ScheduleTeamsBlock {
      teams_count: n_teams,
      teams,
    })
  }
}