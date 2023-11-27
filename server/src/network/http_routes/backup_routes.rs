use log::error;
use rocket::{State, post, http::Status};
use tms_macros::tms_private_route;
use tms_utils::network_schemas::{BackupsRequest, BackupsResponse, RestoreBackupRequest, DeleteBackupRequest, DownloadBackupRequest, DownloadBackupResponse, SocketMessage};
use tms_utils::security::encrypt;
use tms_utils::{with_clients_read, tms_clients_ws_send};
use tms_utils::{TmsRouteResponse, TmsRespond, security::Security, TmsClients, TmsRequest, schemas::create_permissions, check_permissions};

use crate::db::backup_service::BackupServiceArc;
use crate::db::db::TmsDB;

#[tms_private_route]
#[post("/backups/get/<uuid>", data = "<message>")]
pub async fn backups_get_route(message: String, backup_service: &State<BackupServiceArc>) -> TmsRouteResponse<()> {
  let message: BackupsRequest = TmsRequest!(message.clone(), security);

  let perms = create_permissions(); // only admin can get backups
  if check_permissions(clients, uuid.clone(), message.auth_token, perms).await {
    let backups = backup_service.read().await.get_backups_pretty();

    let backup_response = BackupsResponse {
      backups
    };

    let map = with_clients_read(clients, |client_map| {
      client_map.clone()
    }).await;


    match map {
      Ok(map) => {
        TmsRespond!(
          Status::Ok,
          backup_response,
          map,
          uuid
        )
      },
      Err(_) => {
        error!("Failed to get Clients lock");
        TmsRespond!(Status::InternalServerError, "Failed to get Clients lock".to_string());
      }
    }
  }
  
  TmsRespond!(Status::Unauthorized, "Unauthorized".to_string());
}

#[tms_private_route]
#[post("/backups/create/<uuid>", data = "<message>")]
pub async fn backups_create_route(message: String, backup_service: &State<BackupServiceArc>) -> TmsRouteResponse<()> {
  let message: BackupsRequest = TmsRequest!(message.clone(), security);

  let perms = create_permissions(); // only admin can create backups
  if check_permissions(clients, uuid.clone(), message.auth_token, perms).await {
    backup_service.read().await.backup_db(true).await;
    TmsRespond!()
  }
  
  TmsRespond!(Status::Unauthorized, "Unauthorized".to_string());
}

#[tms_private_route]
#[post("/backups/restore/<uuid>", data = "<message>")]
pub async fn backups_restore_route(message: String, backup_service: &State<BackupServiceArc>) -> TmsRouteResponse<()> {
  let message: RestoreBackupRequest = TmsRequest!(message.clone(), security);

  let perms = create_permissions(); // only admin can restore backups
  if check_permissions(clients, uuid.clone(), message.auth_token, perms).await {
    let result = backup_service.read().await.restore_db(message.backup_name.clone()).await;

    match result {
      Ok(_) => {
        // notify clients that the database has been restored

        // send event update
        tms_clients_ws_send(SocketMessage {
          from_id: None,
          topic: String::from("event"),
          sub_topic: String::from("update"),
          message: String::from("")
        }, clients.inner().to_owned(), None).await;
        
        // send teams update
        tms_clients_ws_send(SocketMessage {
          from_id: None,
          topic: String::from("teams"),
          sub_topic: String::from("update"),
          message: String::from("")
        }, clients.inner().to_owned(), None).await;

        // send matches update
        tms_clients_ws_send(SocketMessage {
          from_id: None,
          topic: String::from("matches"),
          sub_topic: String::from("update"),
          message: String::from("")
        }, clients.inner().to_owned(), None).await;

        // send judging sessions update
        tms_clients_ws_send(SocketMessage {
          from_id: None,
          topic: String::from("judging_sessions"),
          sub_topic: String::from("update"),
          message: String::from("")
        }, clients.inner().to_owned(), None).await;

        TmsRespond!()
      },
      Err(_) => {
        error!("Failed to get Backups lock");
        TmsRespond!(Status::InternalServerError, "Failed to get Backups lock".to_string());
      }
    }
  }
  
  TmsRespond!(Status::Unauthorized, "Unauthorized".to_string());
}

#[tms_private_route]
#[post("/backups/delete/<uuid>", data = "<message>")]
pub async fn backups_delete_route(message: String, backup_service: &State<BackupServiceArc>) -> TmsRouteResponse<()> {
  let message: DeleteBackupRequest = TmsRequest!(message.clone(), security);

  let perms = create_permissions(); // only admin can delete backups
  if check_permissions(clients, uuid.clone(), message.auth_token, perms).await {
    backup_service.read().await.delete_backup(message.backup_name.clone());
    TmsRespond!()
  }
  
  TmsRespond!(Status::Unauthorized, "Unauthorized".to_string());
}

#[tms_private_route]
#[post("/backups/download/<uuid>", data = "<message>")]
pub async fn backups_download_route(message: String, backup_service: &State<BackupServiceArc>) -> TmsRouteResponse<()> {
  let message: DownloadBackupRequest = TmsRequest!(message.clone(), security);

  let perms = create_permissions(); // only admin can download backups
  if check_permissions(clients, uuid.clone(), message.auth_token, perms).await {
    // let result = with_backup_service_read(backup_service, |service| {
    //   service.download_backup(message.backup_name.clone())
    // }).await;

    let backup = backup_service.read().await.download_backup(message.backup_name.clone());

    let response = DownloadBackupResponse {
      file_name: message.backup_name.clone(),
      data: Some(backup)
    };

    let map = with_clients_read(clients, |client_map| {
      client_map.clone()
    }).await;

    match map {
      Ok(map) => {
        TmsRespond!(
          Status::Ok,
          response,
          map,
          uuid
        );
      },
      Err(_) => {
        error!("Failed to get Clients lock");
        TmsRespond!(Status::InternalServerError, "Failed to get Clients lock".to_string());
      }
    }
  }


  TmsRespond!(Status::Unauthorized, "Unauthorized".to_string());
}