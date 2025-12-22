use crate::{
  generated::common::TmsDateTime,
  modules::schedule::csv_parser::block::{BLOCK_JUDGING, Block},
};

#[derive(Debug, Clone)]
pub struct ScheduledPodAssignmentT {
  pub pod_name: String,
  pub team_number: String,
}

#[derive(Debug, Clone)]
pub struct ScheduledSessionT {
  pub session_number: String,
  pub start_time: TmsDateTime,
  pub end_time: TmsDateTime,
  pub pod_assignments: Vec<ScheduledPodAssignmentT>,
}

#[derive(Debug, Clone)]
pub struct ScheduledJudging {
  pub pod_names: Vec<String>,
  pub sessions: Vec<ScheduledSessionT>,
}

impl Block for ScheduledJudging {
  type Output = ScheduledJudging;

  fn from_csv(csv: &str) -> Result<Self::Output, String> {
    let block_lines = Self::get_block_lines(csv, BLOCK_JUDGING)?;

    let mut n_judging_teams: usize = 0;
    let mut judging_pod_names: Vec<String> = vec![];
    let mut sessions: Vec<ScheduledSessionT> = vec![];

    for line in block_lines {
      // split
      let fields = line.split(',').collect::<Vec<&str>>();

      // Skip empty lines
      if fields.is_empty() || fields[0].trim().is_empty() {
        continue;
      }

      match fields[0] {
        "Number of Judging Teams" => {
          let teams_str = fields.get(1).unwrap_or(&"0");
          n_judging_teams = match teams_str.parse::<usize>() {
            Ok(n) => n,
            Err(e) => return Err(format!("Error parsing number of judging teams: {}", e)),
          };
        }
        "Number of Judged Events" | "Number of Event Time Slots" | "Event Name" => {}
        "Room Names" => {
          for i in 1..fields.len() {
            // skip first field (which is "Room Names")
            if let Some(room_name) = fields.get(i)
              && !room_name.trim().is_empty()
            {
              judging_pod_names.push(room_name.to_string());
            }
          }
        }

        _ => {
          let mut pod_assignments: Vec<ScheduledPodAssignmentT> = vec![];
          let session_number = fields.first().unwrap_or(&"").to_string();
          let start_time = fields.get(1).unwrap_or(&"").to_string();
          let end_time = fields.get(2).unwrap_or(&"").to_string();

          // Only process if we have at least a session number
          if !session_number.trim().is_empty() {
            for i in 0..n_judging_teams {
              let actual_index = 3 + i;
              if let Some(team_number_field) = fields.get(actual_index) {
                let team_number = team_number_field.to_string();

                // Only add if we have a valid room name at this index
                if let Some(room_name) = judging_pod_names.get(i)
                  && !team_number.trim().is_empty()
                {
                  let in_pod = ScheduledPodAssignmentT { pod_name: room_name.clone(), team_number };
                  pod_assignments.push(in_pod);
                }
              }
            }

            sessions.push(ScheduledSessionT {
              session_number,
              start_time: Self::extract_time(&start_time)?,
              end_time: Self::extract_time(&end_time)?,
              pod_assignments,
            });
          }
        }
      }
    }

    Ok(ScheduledJudging { pod_names: judging_pod_names, sessions })
  }
}
