
use rocket::{*, http::Status};
use rocket::State;
use tms_utils::TmsRouteResponse;
use tms_utils::schemas::{LoginResponse};
use tms_utils::{TmsClients, schemas::LoginRequest, TmsRequest, security::Security, TmsRespond, security::encrypt};
use uuid::Uuid;

use crate::db::db::TmsDB;

#[post("/login/<uuid>", data = "<message>")]
pub fn login_route(security: &State<Security>, clients: &State<TmsClients>, db: &State<TmsDB>, uuid: String, message: String) -> TmsRouteResponse<()> {
  println!("Login route");
  println!("Message string: {}", security.decrypt(message.clone()).as_str());
  let message: LoginRequest = TmsRequest!(message.clone(), security);
  println!("Message: {}, {}", message.username, message.password);

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
      clients.write().unwrap().get_mut(&uuid).unwrap().auth_token = auth_token.to_string();
      // Copy and apply the specified user permissions to the client
      clients.write().unwrap().get_mut(&uuid).unwrap().permissions = user.permissions.clone();
      
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