use crate::{
  auth::{
    auth_helpers::{require_auth, require_permission},
    jwt::Auth,
  },
  generated::{
    api::{
      LoginRequest, LoginResponse, UpdateAdminPasswordRequest, UpdateAdminPasswordResponse, ValidateTokenRequest,
      ValidateTokenResponse, user_service_server::UserService,
    },
    common::Role,
    db::User,
  },
  modules::user::UserRepository,
};

pub struct UserApi;

use tonic::{Request, Response, Result, Status};

#[tonic::async_trait]
impl UserService for UserApi {
  async fn login(&self, request: Request<LoginRequest>) -> Result<Response<LoginResponse>, Status> {
    let request = request.into_inner();

    // standard checks
    if request.username.is_empty() || request.password.is_empty() {
      return Err(Status::invalid_argument("Username or Password empty"));
    }

    let users = match User::get_by_username(&request.username) {
      Ok(u) => u,
      Err(e) => return Err(Status::internal(e.to_string())),
    };

    if users.is_empty() {
      log::error!("User not found: {}", request.username);
      return Err(Status::not_found("User not found"));
    }

    // check user and password (against any potential users)
    let (id, user) = if let Some((id, user)) = users.iter().find(|(_, user)| user.password == request.password) {
      (id, user.clone())
    } else {
      log::error!("Invalid password for user: {}", request.username);
      return Err(Status::unauthenticated("Invalid username or password"));
    };

    // Generate JWT
    let roles: Vec<Role> = user.roles().collect();
    let token = match Auth::generate_token(id, &roles) {
      Ok(t) => t,
      Err(e) => return Err(Status::internal(e.to_string())),
    };

    Ok(Response::new(LoginResponse { token, roles: user.roles }))
  }

  async fn validate_token(
    &self,
    request: Request<ValidateTokenRequest>,
  ) -> Result<Response<ValidateTokenResponse>, Status> {
    require_auth(&request)?;
    Ok(Response::new(ValidateTokenResponse {}))
  }

  async fn update_admin_password(
    &self,
    request: Request<UpdateAdminPasswordRequest>,
  ) -> Result<Response<UpdateAdminPasswordResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let request = request.into_inner();

    match User::set_admin_password(&request.password) {
      Ok(()) => Ok(Response::new(UpdateAdminPasswordResponse {})),
      Err(e) => Err(Status::internal(e.to_string())),
    }
  }
}
