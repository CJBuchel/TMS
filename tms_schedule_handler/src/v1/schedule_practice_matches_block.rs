use super::{ScheduleMatchT, ScheduleOnTableT, V1Block, BLOCK_PRACTICE_MATCHES};

pub struct SchedulePracticeMatchesBlock {
  pub ranking_matches_count: usize,
  pub tables_count: usize,
  pub teams_per_table: usize,
  pub simultaneous_tables: usize,
  pub table_names: Vec<String>,
  pub matches: Vec<ScheduleMatchT>,
}

impl V1Block for SchedulePracticeMatchesBlock {
  type Output = SchedulePracticeMatchesBlock;

  fn from_csv(csv: &str) -> Result<Self::Output, String> {
    let block_lines = match Self::get_block_lines(csv, BLOCK_PRACTICE_MATCHES) {
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

      // Skip empty lines
      if fields.is_empty() || fields[0].trim().is_empty() {
        continue;
      }

      match fields[0] {
        "Number of Practice Matches" => {
          let matches_str = fields.get(1).unwrap_or(&"0");
          n_ranking_matches = match matches_str.parse::<usize>() {
            Ok(n) => n,
            Err(e) => return Err(format!("Error parsing number of practice matches: {}", e)),
          };
        }

        "Number of Tables" => {
          let tables_str = fields.get(1).unwrap_or(&"0");
          n_tables = match tables_str.parse::<usize>() {
            Ok(n) => n,
            Err(e) => return Err(format!("Error parsing number of tables: {}", e)),
          };
        }

        "Number of Teams per Table" => {
          let teams_per_table_str = fields.get(1).unwrap_or(&"0");
          n_teams_per_table = match teams_per_table_str.parse::<usize>() {
            Ok(n) => n,
            Err(e) => return Err(format!("Error parsing number of teams per table: {}", e)),
          };
        }

        "Number of Simultaneous Tables" => {
          let simultaneous_tables_str = fields.get(1).unwrap_or(&"0");
          n_simultaneous_tables = match simultaneous_tables_str.parse::<usize>() {
            Ok(n) => n,
            Err(e) => return Err(format!("Error parsing number of simultaneous tables: {}", e)),
          };
        }

        "Table Names" => {
          // from 1 to n_tables, safely get table names
          for i in 1..fields.len() {
            if let Some(table_name) = fields.get(i) {
              if !table_name.trim().is_empty() {
                table_names.push(table_name.to_string());
              }
            }
          }
        }

        // match number, start time, end time, table 1, team 1, table 2, team 2, ...
        _ => {
          let mut on_tables: Vec<ScheduleOnTableT> = vec![];
          let match_number = fields.get(0).unwrap_or(&"").to_string();
          let start_time = fields.get(1).unwrap_or(&"").to_string();
          let end_time = fields.get(2).unwrap_or(&"").to_string();

          // Only process if we have at least a match number
          if !match_number.trim().is_empty() {
            // from 3 to n_tables
            for i in 0..n_tables {
              // the actual field provides the team number while the relative index provides the table name
              let actual_index = 3 + i;
              if let Some(team_number_field) = fields.get(actual_index) {
                let team_number = team_number_field.to_string();

                // Only add if we have a valid table name at this index
                if let Some(on_table_name) = table_names.get(i) {
                  if !team_number.trim().is_empty() {
                    on_tables.push(ScheduleOnTableT {
                      on_table_name: on_table_name.clone(),
                      team_number,
                    });
                  }
                }
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
    }

    Ok(SchedulePracticeMatchesBlock {
      ranking_matches_count: n_ranking_matches,
      tables_count: n_tables,
      teams_per_table: n_teams_per_table,
      simultaneous_tables: n_simultaneous_tables,
      table_names,
      matches,
    })
  }
}
