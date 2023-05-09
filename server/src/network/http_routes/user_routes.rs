
use rocket::{*, http::Status};
use rocket::State;
use tms_utils::TmsRouteResponse;
use tms_utils::schemas::LoginResponse;
use tms_utils::{TmsClients, schemas::{LoginRequest, User}, TmsRequest, security::Security, TmsRespond, security::encrypt};
use uuid::Uuid;

use crate::db::db::TmsDB;

fn login_user(user: User, uuid: String, clients: TmsClients, message: LoginRequest) -> TmsRouteResponse<()> {
  if user.password == message.password {
    if clients.read().unwrap().contains_key(&uuid) {
      let auth_token = Uuid::new_v4();
      clients.write().unwrap().get_mut(&uuid).unwrap().auth_token = auth_token.to_string();
      clients.write().unwrap().get_mut(&uuid).unwrap().permissions = user.permissions;
      let res = LoginResponse { auth_token: auth_token.to_string() };
      TmsRespond!(
        Status::Ok,
        res,
        clients,
        uuid
      )
    }
  }

  TmsRespond!(Status::BadRequest)
}

#[post("/login/<uuid>", data = "<message>")]
pub fn login_route(security: &State<Security>, clients: &State<TmsClients>, db: &State<TmsDB>, uuid: String, message: String) -> TmsRouteResponse<()> {
  println!("Login route");
  println!("Message string: {}", security.decrypt(message.clone()).as_str());
  let message: LoginRequest = TmsRequest!(message.clone(), security);
  println!("Message: {}, {}", message.username, message.password);

  match db.tms_data.users.get(message.username.clone()).unwrap() {
    Some(user) => {
      println!("User found, logging in");
      return login_user(user, uuid, clients.inner().clone(), message);
    },
    None => {
      println!("No user matching, returning bad request");
      TmsRespond!(Status::BadRequest)
    }
  }
}