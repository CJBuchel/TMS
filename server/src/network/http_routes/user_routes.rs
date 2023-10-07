
use ::log::warn;
use rocket::{*, http::Status};
use rocket::State;
use tms_macros::tms_private_route;
use tms_utils::schemas::{create_permissions, User};
use tms_utils::{TmsRouteResponse, with_clients_write, check_permissions};
use tms_utils::network_schemas::{LoginResponse, LoginRequest, UsersRequest, UsersResponse, AddUserRequest, DeleteUserRequest, UpdateUserRequest};
use tms_utils::{TmsClients, TmsRequest, security::Security, TmsRespond, security::encrypt};
use uuid::Uuid;
use crate::db::tree::UpdateTree;

use crate::db::db::TmsDB;

#[tms_private_route]
#[post("/login/<uuid>", data = "<message>")]
pub fn login_route(message: String) -> TmsRouteResponse<()> {
  let message: LoginRequest = TmsRequest!(message.clone(), security);
  let user = match db.tms_data.users.get(message.username.clone()).unwrap() {
    Some(user) => user,
    None => {
      TmsRespond!(Status::Unauthorized)
    }
  };

  // Check if credentials match
  if user.password == message.password {
    if clients.read().unwrap().contains_key(&uuid) {
      // Generate auth token and apply it to the client connection
      let auth_token = Uuid::new_v4();
      with_clients_write(&clients, |client_map| {
        client_map.get_mut(&uuid).unwrap().auth_token = auth_token.to_string();
        // Copy and apply the specified user permissions to the client
        client_map.get_mut(&uuid).unwrap().permissions = user.permissions.clone();
      }).unwrap();
      
      // Respond to the client with the auth token
      let res = LoginResponse {
        auth_token: auth_token.to_string(),
        permissions: user.permissions,
      };

      TmsRespond!(
        Status::Ok,
        res,
        clients,
        uuid
      )
    }
  }

  // If fall through logic
  TmsRespond!(Status::Unauthorized)
}

#[tms_private_route]
#[post("/users/get/<uuid>", data = "<message>")]
pub fn users_get_route(message: String) -> TmsRouteResponse<()> {
  // get all users except for admin
  let users_request: UsersRequest = TmsRequest!(message.clone(), security);
  let perms = create_permissions();

  if check_permissions(clients, uuid.clone(), users_request.auth_token, perms) {
    let mut users:Vec<User> = vec![];
    for user_raw in db.tms_data.users.iter() {
      let user = match user_raw {
        Ok(user) => user.1,
        _ => {
          error!("Failed to get user");
          TmsRespond!(Status::BadRequest, "Failed to get user".to_string());
        }
      };

      if user.username != "admin" { // don't ever provide admin user
        users.push(user.clone());
      }
    }

    let users_response = UsersResponse {
      users
    };

    TmsRespond!(
      Status::Ok,
      users_response,
      clients,
      uuid
    )
  }


  TmsRespond!(Status::Unauthorized)
}

#[tms_private_route]
#[post("/user/add/<uuid>", data = "<message>")]
pub fn user_add_route(message: String) -> TmsRouteResponse<()> {
  let add_user_request: AddUserRequest = TmsRequest!(message.clone(), security);
  let perms = create_permissions();

  if check_permissions(clients, uuid.clone(), add_user_request.auth_token, perms) {
    let user = add_user_request.user;
    let username = user.username.clone();
    let password = user.password.clone();
    let permissions = user.permissions.clone();

    // Check if user already exists
    match db.tms_data.users.get(&username).unwrap() {
      Some(_) => {
        TmsRespond!(Status::BadRequest, "User already exists".to_string());
      },
      None => {
        let user = User {
          username: username.clone(),
          password: password.clone(),
          permissions: permissions.clone()
        };

        let _ = db.tms_data.users.insert(username.as_bytes(), user.clone());
        // Respond to client
        TmsRespond!(
          Status::Ok,
          "User added successfully".to_string(),
          clients,
          uuid
        )
      }
    }
  }

  TmsRespond!(Status::Unauthorized)
}

#[tms_private_route]
#[post("/user/delete/<uuid>", data = "<message>")]
pub fn user_delete_route(message: String) -> TmsRouteResponse<()> {
  let delete_user_request: DeleteUserRequest = TmsRequest!(message.clone(), security);
  let perms = create_permissions();

  if check_permissions(clients, uuid.clone(), delete_user_request.auth_token, perms) {
    let username = delete_user_request.username.clone();
    
    // if username is admin, don't allow deletion
    if username == "admin" {
      TmsRespond!(Status::Forbidden, "Cannot delete admin user".to_string());
    } else {

      // Check if user already exists
      match db.tms_data.users.get(&username).unwrap() {
        Some(_) => {
          let _ = db.tms_data.users.remove(&username);
          // Respond to client
          TmsRespond!(
            Status::Ok,
            "User deleted successfully".to_string(),
            clients,
            uuid
          )
        },
        None => {
          TmsRespond!(Status::BadRequest, "User does not exist".to_string());
        }
      }
    }
  }

  TmsRespond!(Status::Unauthorized)
}

#[tms_private_route]
#[post("/user/update/<uuid>", data = "<message>")]
pub fn user_update_route(message: String) -> TmsRouteResponse<()> {
  let update_user_request: UpdateUserRequest = TmsRequest!(message.clone(), security);
  let perms = create_permissions();

  if check_permissions(clients, uuid.clone(), update_user_request.auth_token, perms) {
    let username = update_user_request.username.clone();
    let updated_user = update_user_request.updated_user.clone();

    warn!("Updating user: {:?}", username);
    
    // if username is admin, don't allow update
    if username == "admin" {
      TmsRespond!(Status::Forbidden, "Cannot update admin user".to_string());
    } else {

      // Check if user already exists
      match db.tms_data.users.get(username.as_bytes()).unwrap() {
        Some(_) => {
          let _ = db.tms_data.users.update(username.as_bytes(), update_user_request.updated_user.username.as_bytes(), updated_user.clone());
          // Respond to client
          TmsRespond!(
            Status::Ok,
            "User updated successfully".to_string(),
            clients,
            uuid
          )
        },
        None => {
          TmsRespond!(Status::NotFound, "User does not exist".to_string());
        }
      }
    }
  }

  TmsRespond!(Status::Unauthorized)
}