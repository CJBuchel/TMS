use super::{V1Block, BLOCK_JUDGING};

#[derive(Clone)]
pub struct ScheduleInRoomT {
  pub room_name: String,
  pub team_number: String,
}

#[derive(Clone)]
pub struct ScheduleSessionT {
  pub session_number: String,
  pub start_time: String, // format "Day name HH:MM:SS AM/PM"
  pub end_time: String,   // format "Day name HH:MM:SS AM/PM"
  pub in_rooms: Vec<ScheduleInRoomT>,
}

pub struct ScheduleJudgeBlock {
  pub judging_events_count: usize,
  pub judging_time_slots_count: usize,
  pub judging_teams_count: usize,
  pub judging_event_name: String,
  pub judging_room_names: Vec<String>,
  pub sessions: Vec<ScheduleSessionT>,
}

impl V1Block for ScheduleJudgeBlock {
  type Output = ScheduleJudgeBlock;

  fn from_csv(csv: &str) -> Result<Self::Output, String> {
    let block_lines = match Self::get_block_lines(csv, BLOCK_JUDGING) {
      Ok(lines) => lines,
      Err(e) => return Err(e),
    };

    let mut n_judging_events: usize = 0;
    let mut n_judging_time_slots: usize = 0;
    let mut n_judging_teams: usize = 0;
    let mut judging_event_name: String = "".to_string();
    let mut judging_room_names: Vec<String> = vec![];
    let mut sessions: Vec<ScheduleSessionT> = vec![];

    for line in block_lines {
      // split
      let fields = line.split(",").collect::<Vec<&str>>();

      // Skip empty lines
      if fields.is_empty() || fields[0].trim().is_empty() {
        continue;
      }

      match fields[0] {
        "Number of Judged Events" => {
          let events_str = fields.get(1).unwrap_or(&"0");
          n_judging_events = match events_str.parse::<usize>() {
            Ok(n) => n,
            Err(e) => return Err(format!("Error parsing number of judging events: {}", e)),
          };
        }

        "Number of Event Time Slots" => {
          let time_slots_str = fields.get(1).unwrap_or(&"0");
          n_judging_time_slots = match time_slots_str.parse::<usize>() {
            Ok(n) => n,
            Err(e) => return Err(format!("Error parsing number of judging time slots: {}", e)),
          };
        }

        "Number of Judging Teams" => {
          let teams_str = fields.get(1).unwrap_or(&"0");
          n_judging_teams = match teams_str.parse::<usize>() {
            Ok(n) => n,
            Err(e) => return Err(format!("Error parsing number of judging teams: {}", e)),
          };
        }

        "Event Name" => {
          judging_event_name = fields.get(1).unwrap_or(&"").to_string();
        }

        "Room Names" => {
          for i in 1..fields.len() {
            // skip first field (which is "Room Names")
            if let Some(room_name) = fields.get(i) {
              if !room_name.trim().is_empty() {
                judging_room_names.push(room_name.to_string());
              }
            }
          }
        }

        _ => {
          let mut in_rooms: Vec<ScheduleInRoomT> = vec![];
          let session_number = fields.get(0).unwrap_or(&"").to_string();
          let start_time = fields.get(1).unwrap_or(&"").to_string();
          let end_time = fields.get(2).unwrap_or(&"").to_string();

          // Only process if we have at least a session number
          if !session_number.trim().is_empty() {
            for i in 0..n_judging_teams {
              let actual_index = 3 + i;
              if let Some(team_number_field) = fields.get(actual_index) {
                let team_number = team_number_field.to_string();

                // Only add if we have a valid room name at this index
                if let Some(room_name) = judging_room_names.get(i) {
                  if !team_number.trim().is_empty() {
                    let in_room = ScheduleInRoomT { room_name: room_name.clone(), team_number };
                    in_rooms.push(in_room);
                  }
                }
              }
            }

            sessions.push(ScheduleSessionT {
              session_number,
              start_time,
              end_time,
              in_rooms,
            });
          }
        }
      }
    }

    Ok(ScheduleJudgeBlock {
      judging_events_count: n_judging_events,
      judging_time_slots_count: n_judging_time_slots,
      judging_teams_count: n_judging_teams,
      judging_event_name,
      judging_room_names,
      sessions,
    })
  }
}
