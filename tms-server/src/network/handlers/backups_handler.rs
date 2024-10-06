use crate::database::*;
use regex::Regex;

pub async fn get_backups_handler(db: SharedDatabase) -> Result<impl warp::Reply, warp::Rejection> {
  let read_db = db.read().await;

  let backup_files = read_db.get_inner().read().await.get_backups("backups/").await;

  log::info!("Backup files: {:?}", backup_files);

  // file format looks like this Test_2-backup-2024-07-20_20-21-58.kvdb.zip

  // extract date time from file name
  let re = Regex::new(r"(\d{4})-(\d{2})-(\d{2})_(\d{2})-(\d{2})-(\d{2})").unwrap();

  let mut backups: Vec<BackupInfo> = Vec::new();


  for file in backup_files.iter() {
    let mut timestamp = TmsDateTime::default();
    let cap = re.captures(file);
    if let Some(c) = cap {

      let year = match c.get(1) {
        Some(year) => year.as_str().parse::<i32>().unwrap_or_default(),
        None => {
          log::error!("Failed to parse year from backup file name: {}", file);
          0
        },
      };

      let month = match c.get(2) {
        Some(month) => month.as_str().parse::<u32>().unwrap_or_default(),
        None => {
          log::error!("Failed to parse month from backup file name: {}", file);
          0
        },
      };

      let day = match c.get(3) {
        Some(day) => day.as_str().parse::<u32>().unwrap_or_default(),
        None => {
          log::error!("Failed to parse day from backup file name: {}", file);
          0
        },
      };

      let hour = match c.get(4) {
        Some(hour) => hour.as_str().parse::<u32>().unwrap_or_default(),
        None => {
          log::error!("Failed to parse hour from backup file name: {}", file);
          0
        },
      };

      let minute = match c.get(5) {
        Some(minute) => minute.as_str().parse::<u32>().unwrap_or_default(),
        None => {
          log::error!("Failed to parse minute from backup file name: {}", file);
          0
        },
      };

      let second = match c.get(6) {
        Some(second) => second.as_str().parse::<u32>().unwrap_or_default(),
        None => {
          log::error!("Failed to parse second from backup file name: {}", file);
          0
        },
      };

      timestamp.date = Some(TmsDate::new(
        year,
        month,
        day,
      ));
      timestamp.time = Some(TmsTime::new(
        hour,
        minute,
        second,
      ));
    }

    backups.push(BackupInfo {
      file_name: file.to_string(),
      timestamp,
    });
  }

  if backup_files.is_empty() {
    return Err(warp::reject::custom(crate::network::BadRequestWithMessage { message: "No backups found".to_string() }));
  } else {
    return Ok(warp::reply::json(&BackupResponse { backups }));
  }
}