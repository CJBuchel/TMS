
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::{DataSchemeExtensions, TmsDateTime};

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct BackupGetNamesInfo {
  pub file_name: String,
  pub timestamp: TmsDateTime,
}

impl Default for BackupGetNamesInfo {
  fn default() -> Self {
    Self {
      file_name: "".to_string(),
      timestamp: TmsDateTime::default(),
    }
  }
}


#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct BackupGetNamesResponse {
  pub backups: Vec<BackupGetNamesInfo>,
}

impl Default for BackupGetNamesResponse {
  fn default() -> Self {
    Self {
      backups: vec![],
    }
  }
}

#[derive(Serialize, Deserialize, Debug, JsonSchema)]
pub struct BackupRestoreRequest {
  pub file_name: String,
}

impl Default for BackupRestoreRequest {
  fn default() -> Self {
    Self {
      file_name: "".to_string(),
    }
  }
}

impl DataSchemeExtensions for BackupGetNamesInfo {}
impl DataSchemeExtensions for BackupGetNamesResponse {}
impl DataSchemeExtensions for BackupRestoreRequest {}