
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::{DataSchemeExtensions, TmsDateTime};

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct BackupInfo {
  pub file_name: String,
  pub timestamp: TmsDateTime,
}

impl Default for BackupInfo {
  fn default() -> Self {
    Self {
      file_name: "".to_string(),
      timestamp: TmsDateTime::default(),
    }
  }
}


#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct BackupResponse {
  pub backups: Vec<BackupInfo>,
}

impl Default for BackupResponse {
  fn default() -> Self {
    Self {
      backups: vec![],
    }
  }
}

impl DataSchemeExtensions for BackupInfo {}
impl DataSchemeExtensions for BackupResponse {}