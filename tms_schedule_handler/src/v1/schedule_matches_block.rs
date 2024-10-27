use super::{V1Block, BLOCK_MATCHES};

#[derive(Clone)]
pub struct ScheduleOnTableT {
  pub on_table_name: String,
  pub team_number: String,
}

#[derive(Clone)]
pub struct ScheduleMatchT {
  pub match_number: String,
  pub start_time: String, // format "Day name HH:MM:SS AM/PM"
  pub end_time: String, // format "Day name HH:MM:SS AM/PM"
  pub on_tables: Vec<ScheduleOnTableT>,
}

pub struct ScheduleMatchesBlock {
  pub ranking_matches_count: usize,
  pub tables_count: usize,
  pub teams_per_table: usize,
  pub simultaneous_tables: usize,
  pub table_names: Vec<String>,
  pub matches: Vec<ScheduleMatchT>,
}

impl V1Block for ScheduleMatchesBlock {
  type Output = ScheduleMatchesBlock;

  fn from_csv(csv: &str) -> Result<Self::Output, String> {
    let block_lines = match Self::get_block_lines(csv, BLOCK_MATCHES) {
      Ok(lines) => lines,
      Err(e) => return Err(e),
    };

    let mut n_ranking_matches: usize = 0;
    let mut n_tables: usize = 0;
    let mut n_teams_per_table: usize = 0;
    let mut n_simultaneous_tables: usize = 0;
    let mut table_names: Vec<String> = vec![];
    let mut matches: Vec<ScheduleMatchT> = vec![];

    for line in block_lines {
      // split
      let fields = line.split(",").collect::<Vec<&str>>();

      match fields[0] {
        "Number of Ranking Matches" => {
          n_ranking_matches = match fields[1].parse::<usize>() {
            Ok(n) => n,
            Err(e) => return Err(format!("Error parsing number of ranking matches: {}", e)),
          };
        },

        "Number of Tables" => {
          n_tables = match fields[1].parse::<usize>() {
            Ok(n) => n,
            Err(e) => return Err(format!("Error parsing number of tables: {}", e)),
          };
        },

        "Number of Teams per Table" => {
          n_teams_per_table = match fields[1].parse::<usize>() {
            Ok(n) => n,
            Err(e) => return Err(format!("Error parsing number of teams per table: {}", e)),
          };
        },

        "Number of Simultaneous Tables" => {
          n_simultaneous_tables = match fields[1].parse::<usize>() {
            Ok(n) => n,
            Err(e) => return Err(format!("Error parsing number of simultaneous tables: {}", e)),
          };
        },

        "Table Names" => {
          // from 1 to n_tables
          for i in 1..=n_tables {
            if !fields[i].is_empty() {
              table_names.push(fields[i].to_string());
            }
          }
        },

        // match number, start time, end time, table 1, team 1, table 2, team 2, ...
        _ => {
          let mut on_tables: Vec<ScheduleOnTableT> = vec![];
          let match_number = fields[0].to_string();
          let start_time = fields[1].to_string();
          let end_time = fields[2].to_string();

          // from 3 to n_tables
          for i in 0..n_tables {
            // the actual field provides the team number while the relative index provides the table name
            let actual_index = 3 + i;
            let team_number = fields[actual_index].to_string();
            let on_table_name = table_names[i].clone();

            if !team_number.is_empty() {
              on_tables.push(ScheduleOnTableT {
                on_table_name,
                team_number,
              });
            }
          }

          matches.push(ScheduleMatchT {
            match_number,
            start_time,
            end_time,
            on_tables,
          });
        }
      }
    }

    Ok(ScheduleMatchesBlock {
      ranking_matches_count: n_ranking_matches,
      tables_count: n_tables,
      teams_per_table: n_teams_per_table,
      simultaneous_tables: n_simultaneous_tables,
      table_names,
      matches,
    })
  }
}