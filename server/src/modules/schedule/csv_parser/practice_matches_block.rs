use crate::modules::schedule::csv_parser::{
  block::{BLOCK_PRACTICE_MATCHES, Block},
  matches_block::{ScheduledMatchT, ScheduledTableAssignmentT},
};

#[derive(Debug, Clone)]
pub struct ScheduledPracticeMatches {
  pub matches: Vec<ScheduledMatchT>,
}

impl Block for ScheduledPracticeMatches {
  type Output = ScheduledPracticeMatches;

  fn from_csv(csv: &str) -> Result<Self::Output, String> {
    let block_lines = Self::get_block_lines(csv, BLOCK_PRACTICE_MATCHES)?;

    let mut n_tables: usize = 0;
    let mut table_names: Vec<String> = vec![];
    let mut matches: Vec<ScheduledMatchT> = vec![];

    for line in block_lines {
      // split
      let fields = line.split(',').collect::<Vec<&str>>();

      // Skip empty lines
      if fields.is_empty() || fields[0].trim().is_empty() {
        continue;
      }

      match fields[0] {
        "Number of Tables" => {
          let tables_str = fields.get(1).unwrap_or(&"0");
          n_tables = match tables_str.parse::<usize>() {
            Ok(n) => n,
            Err(e) => return Err(format!("Error parsing number of tables: {}", e)),
          };
        }
        "Number of Practice Matches" | "Number of Teams per Table" | "Number of Simultaneous Tables" => {}
        "Table Names" => {
          // from 1 to n_tables, safely get table names
          for i in 1..fields.len() {
            if let Some(table_name) = fields.get(i)
              && !table_name.trim().is_empty()
            {
              table_names.push(table_name.to_string());
            }
          }
        }

        // match number, start time, end time, table 1, team 1, table 2, team 2, ...
        _ => {
          let mut table_assignments: Vec<ScheduledTableAssignmentT> = vec![];
          let match_number = fields.first().unwrap_or(&"").to_string();
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
                if let Some(on_table_name) = table_names.get(i)
                  && !team_number.trim().is_empty()
                {
                  table_assignments.push(ScheduledTableAssignmentT {
                    table_name: on_table_name.clone(),
                    team_number,
                  });
                }
              }
            }

            matches.push(ScheduledMatchT {
              match_number,
              start_time: Self::extract_time(&start_time)?,
              end_time: Self::extract_time(&end_time)?,
              table_assignments,
            });
          }
        }
      }
    }

    Ok(ScheduledPracticeMatches { matches })
  }
}
