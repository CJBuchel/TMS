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
  pub end_time: String, // format "Day name HH:MM:SS AM/PM"
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

      match fields[0] {
        "Number of Judged Events" => {
          n_judging_events = match fields[1].parse::<usize>() {
            Ok(n) => n,
            Err(e) => return Err(format!("Error parsing number of judging events: {}", e)),
          };
        },

        "Number of Event Time Slots" => {
          n_judging_time_slots = match fields[1].parse::<usize>() {
            Ok(n) => n,
            Err(e) => return Err(format!("Error parsing number of judging time slots: {}", e)),
          };
        },

        "Number of Judging Teams" => {
          n_judging_teams = match fields[1].parse::<usize>() {
            Ok(n) => n,
            Err(e) => return Err(format!("Error parsing number of judging teams: {}", e)),
          };
        },

        "Event Name" => {
          judging_event_name = fields[1].to_string();
        },

        "Room Names" => {
          judging_room_names = fields[1..].iter().map(|s| s.to_string()).collect();
        },

        _ => {
          let mut in_rooms: Vec<ScheduleInRoomT> = vec![];
          let session_number = fields[0].to_string();
          let start_time = fields[1].to_string();
          let end_time = fields[2].to_string();

          for i in 0..n_judging_teams {
            let actual_index = 3 + i;
            let team_number = fields[actual_index].to_string();
            let room_name = judging_room_names[i].clone();

            if !team_number.is_empty() {
              let in_room = ScheduleInRoomT {
                room_name,
                team_number,
              };
              in_rooms.push(in_room);
            }
          }

          sessions.push(ScheduleSessionT {
            session_number,
            start_time,
            end_time,
            in_rooms,
          });
        },
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