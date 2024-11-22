use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

use crate::infra::DataSchemeExtensions;

use super::{ADMIN_ROLE, AV_ROLE, EMCEE_ROLE, HEAD_REFEREE_ROLE, JUDGE_ADVISOR_ROLE, JUDGE_ROLE, REFEREE_ROLE, SCORE_KEEPER_ROLE};

#[derive(Clone, Debug, Serialize, Deserialize, JsonSchema)]
pub struct UserPermissions {
  // hard coded roles
  pub admin: Option<bool>,
  pub referee: Option<bool>,
  pub head_referee: Option<bool>,
  pub judge: Option<bool>,
  pub judge_advisor: Option<bool>,
  pub score_keeper: Option<bool>,
  pub emcee: Option<bool>,
  pub av: Option<bool>,
}

impl UserPermissions {
  // optional new`
  
  pub fn new(
    admin: Option<bool>,
    referee: Option<bool>,
    head_referee: Option<bool>,
    judge: Option<bool>,
    judge_advisor: Option<bool>,
    score_keeper: Option<bool>,
    emcee: Option<bool>,
    av: Option<bool>,
  ) -> Self {
    Self {
      admin,
      referee,
      head_referee,
      judge,
      judge_advisor,
      score_keeper,
      emcee,
      av,
    }
  }

  
  pub fn get_merged_permissions(&self, permissions: UserPermissions) -> UserPermissions {
    let mut merged_permissions = self.clone();

    merged_permissions.admin = permissions.admin.or(self.admin);
    merged_permissions.referee = permissions.referee.or(self.referee);
    merged_permissions.head_referee = permissions.head_referee.or(self.head_referee);
    merged_permissions.judge = permissions.judge.or(self.judge);
    merged_permissions.judge_advisor = permissions.judge_advisor.or(self.judge_advisor);
    merged_permissions.score_keeper = permissions.score_keeper.or(self.score_keeper);
    merged_permissions.emcee = permissions.emcee.or(self.emcee);
    merged_permissions.av = permissions.av.or(self.av);

    merged_permissions
  }

  
  pub fn from_roles(roles: Vec<String>) -> Self {
    let mut permissions = Self::default();

    for role in roles {
      match role.as_str() {
        ADMIN_ROLE => permissions.admin = Some(true),
        REFEREE_ROLE => permissions.referee = Some(true),
        HEAD_REFEREE_ROLE => permissions.head_referee = Some(true),
        JUDGE_ROLE => permissions.judge = Some(true),
        JUDGE_ADVISOR_ROLE => permissions.judge_advisor = Some(true),
        SCORE_KEEPER_ROLE => permissions.score_keeper = Some(true),
        EMCEE_ROLE => permissions.emcee = Some(true),
        AV_ROLE => permissions.av = Some(true),
        _ => {}
      }
    }

    permissions
  }

  
  pub fn get_roles(&self) -> Vec<String> {
    let mut roles = vec![];

    if self.admin.unwrap_or(false) {
      roles.push(ADMIN_ROLE.to_string());
    }

    if self.referee.unwrap_or(false) {
      roles.push(REFEREE_ROLE.to_string());
    }

    if self.head_referee.unwrap_or(false) {
      roles.push(HEAD_REFEREE_ROLE.to_string());
    }

    if self.judge.unwrap_or(false) {
      roles.push(JUDGE_ROLE.to_string());
    }

    if self.judge_advisor.unwrap_or(false) {
      roles.push(JUDGE_ADVISOR_ROLE.to_string());
    }

    if self.score_keeper.unwrap_or(false) {
      roles.push(SCORE_KEEPER_ROLE.to_string());
    }

    if self.emcee.unwrap_or(false) {
      roles.push(EMCEE_ROLE.to_string());
    }

    if self.av.unwrap_or(false) {
      roles.push(AV_ROLE.to_string());
    }

    roles
  } 

  
  pub fn has_role_access(&self, roles: Vec<String>) -> bool {
    // admin always has access, regardless of current set permissions
    let role_access = Self::from_roles(roles.to_owned());
    if role_access.admin.unwrap_or(false) {
      return true;
    }

    let mut has_access = false;

    // referee
    if self.referee.unwrap_or(false) {
      // both referee & head_referee have access to the same resources
      if roles.contains(&REFEREE_ROLE.to_string()) || roles.contains(&HEAD_REFEREE_ROLE.to_string()) {
        has_access = true;
      }
    }

    // head referee
    if self.head_referee.unwrap_or(false) {
      if roles.contains(&HEAD_REFEREE_ROLE.to_string()) {
        has_access = true;
      }
    }

    // judge
    if self.judge.unwrap_or(false) {
      // judge advisor has access to the same resources as judge
      if roles.contains(&JUDGE_ROLE.to_string()) || roles.contains(&JUDGE_ADVISOR_ROLE.to_string()) {
        has_access = true;
      }
    }

    // judge advisor
    if self.judge_advisor.unwrap_or(false) {
      if roles.contains(&JUDGE_ADVISOR_ROLE.to_string()) {
        has_access = true;
      }
    }

    // scorekeeper
    if self.score_keeper.unwrap_or(false) {
      if roles.contains(&SCORE_KEEPER_ROLE.to_string()) {
        has_access = true;
      }
    }

    // emcee
    if self.emcee.unwrap_or(false) {
      if roles.contains(&EMCEE_ROLE.to_string()) {
        has_access = true;
      }
    }

    // av
    if self.av.unwrap_or(false) {
      if roles.contains(&AV_ROLE.to_string()) {
        has_access = true;
      }
    }

    has_access
  }
}

impl Default for UserPermissions {
  fn default() -> Self {
    Self {
      admin: None,
      referee: None,
      head_referee: None,
      judge: None,
      judge_advisor: None,
      score_keeper: None,
      emcee: None,
      av: None,
    }
  }
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct User {
  pub username: String,
  pub password: String,
  pub roles: Vec<String>, // roles from the role manager
}

impl User {
  
  pub fn new(username: &str, password: &str, roles: Vec<String>) -> Self {
    Self {
      username: username.to_string(),
      password: password.to_string(),
      roles,
    }
  }

  
  pub fn has_role(&self, role: &str) -> bool {
    self.roles.contains(&role.to_string())
  }

  
  pub fn has_permission_access(&self, permissions: &UserPermissions) -> bool {
    permissions.has_role_access(self.roles.clone())
  }

  
  pub fn has_role_access(&self, roles: Vec<String>) -> bool {
    let permissions = UserPermissions::from_roles(self.roles.clone());
    permissions.has_role_access(roles)
  }

  
  pub fn get_permissions(&self) -> UserPermissions {
    UserPermissions::from_roles(self.roles.clone())
  }
}

impl Default for User {
  fn default() -> Self {
    Self {
      username: "".to_string(),
      password: "".to_string(),
      roles: vec!["public".to_string()],
    }
  }
}

impl DataSchemeExtensions for UserPermissions {}
impl DataSchemeExtensions for User {}