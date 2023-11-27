use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::schemas::Backup;


#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct BackupsRequest {
  pub auth_token: String,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct BackupsResponse {
  pub backups: Vec<Backup>,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct DeleteBackupRequest {
  pub auth_token: String,
  pub backup_name: String,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct RestoreBackupRequest {
  pub auth_token: String,
  pub backup_name: String,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct DownloadBackupRequest {
  pub auth_token: String,
  pub backup_name: String,
}

#[derive(JsonSchema, Deserialize, Serialize, Clone)]
pub struct DownloadBackupResponse {
  pub file_name: String,
  pub data: Option<Vec<u8>>, // binary format of the backup
}