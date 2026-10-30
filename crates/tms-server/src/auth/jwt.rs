//! Login tokens are HS256 JWTs. Verifying one needs no database lookup: the signature and expiry are checked,
//! then an in-memory revocation list (loaded from the database at start, updated on every revoke) is consulted.
//! That keeps logout, password changes, disabled users and revoked access keys effective immediately.

use std::collections::{HashMap, HashSet};
use std::sync::RwLock;

use anyhow::Context;
use chrono::{DateTime, TimeDelta, Utc};
use jsonwebtoken::{Algorithm, DecodingKey, EncodingKey, Header, Validation, decode, encode};
use serde::{Deserialize, Serialize};
use sqlx::PgPool;
use tms_core::Role;
use tms_core::dto::{Identity, Principal};
use tokio::sync::broadcast;
use uuid::Uuid;

pub const USER_TOKEN_TTL: TimeDelta = TimeDelta::hours(12);
pub const KEY_TOKEN_TTL: TimeDelta = TimeDelta::hours(24);
const SECRET_NAME: &str = "jwt_hs256";

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Claims {
  /// The user or access key id.
  pub sub: Uuid,
  pub jti: Uuid,
  pub iat: i64,
  pub exp: i64,
  /// Issue time in milliseconds, so a revocation made in the same second as a new login is ordered correctly.
  pub iat_ms: i64,
  pub principal: Principal,
  pub roles: Vec<Role>,
  pub must_change_password: bool,
}

impl Claims {
  pub fn identity(&self) -> Identity {
    Identity {
      principal: self.principal.clone(),
      roles: self.roles.clone(),
      must_change_password: self.must_change_password,
    }
  }

  pub fn expires_at(&self) -> DateTime<Utc> {
    DateTime::from_timestamp(self.exp, 0).unwrap_or_default()
  }

  fn user_id(&self) -> Option<Uuid> {
    matches!(self.principal, Principal::User { .. }).then_some(self.sub)
  }

  fn key_id(&self) -> Option<Uuid> {
    matches!(self.principal, Principal::Key { .. }).then_some(self.sub)
  }
}

/// Something that makes existing tokens invalid. Broadcast so open WebSockets using them are closed.
#[derive(Debug, Clone, PartialEq)]
pub enum Revocation {
  /// One token (logout).
  Token { jti: Uuid, expires_at: DateTime<Utc> },
  /// Every token a user received before this instant (password change, role change, disable).
  UserBefore { user_id: Uuid, before: DateTime<Utc> },
  /// Every token issued for an access key.
  Key(Uuid),
}

impl Revocation {
  pub fn affects(&self, claims: &Claims) -> bool {
    match self {
      Revocation::Token { jti, .. } => claims.jti == *jti,
      Revocation::UserBefore { user_id, before } => {
        claims.user_id() == Some(*user_id) && claims.iat_ms < before.timestamp_millis()
      }
      Revocation::Key(key_id) => claims.key_id() == Some(*key_id),
    }
  }
}

#[derive(Default)]
struct Revoked {
  tokens: HashMap<Uuid, i64>,
  users_before_ms: HashMap<Uuid, i64>,
  keys: HashSet<Uuid>,
}

pub struct AuthState {
  encoding: EncodingKey,
  decoding: DecodingKey,
  validation: Validation,
  revoked: RwLock<Revoked>,
  events: broadcast::Sender<Revocation>,
}

impl AuthState {
  /// Loads (or creates) the signing secret and the current revocations.
  pub async fn load(pool: &PgPool) -> anyhow::Result<Self> {
    let candidate = rand::random::<[u8; 64]>().to_vec();
    sqlx::query!(
      "insert into server_secrets (name, value) values ($1, $2) on conflict (name) do nothing",
      SECRET_NAME,
      candidate
    )
    .execute(pool)
    .await?;
    let secret = sqlx::query_scalar!("select value from server_secrets where name = $1", SECRET_NAME)
      .fetch_one(pool)
      .await
      .context("reading the JWT secret")?;

    sqlx::query!("delete from revoked_tokens where expires_at < now()")
      .execute(pool)
      .await?;
    let mut revoked = Revoked::default();
    for row in sqlx::query!("select jti, expires_at from revoked_tokens")
      .fetch_all(pool)
      .await?
    {
      revoked.tokens.insert(row.jti, row.expires_at.timestamp());
    }
    for row in sqlx::query!(
      "select id, disabled, tokens_valid_after from users where disabled or tokens_valid_after is not null"
    )
    .fetch_all(pool)
    .await?
    {
      let before = if row.disabled {
        i64::MAX
      } else {
        row.tokens_valid_after.map_or(0, |t| t.timestamp_millis())
      };
      revoked.users_before_ms.insert(row.id, before);
    }
    for id in sqlx::query_scalar!("select id from access_keys where revoked_at is not null")
      .fetch_all(pool)
      .await?
    {
      revoked.keys.insert(id);
    }

    Ok(Self::from_parts(&secret, revoked))
  }

  fn from_parts(secret: &[u8], revoked: Revoked) -> Self {
    let mut validation = Validation::new(Algorithm::HS256);
    validation.leeway = 30;
    Self {
      encoding: EncodingKey::from_secret(secret),
      decoding: DecodingKey::from_secret(secret),
      validation,
      revoked: RwLock::new(revoked),
      events: broadcast::channel(256).0,
    }
  }

  /// Signs a token valid for `ttl`, or until `not_after` if that is sooner (an access key's own expiry).
  pub fn issue(
    &self,
    principal: Principal,
    roles: Vec<Role>,
    must_change_password: bool,
    ttl: TimeDelta,
    not_after: Option<DateTime<Utc>>,
  ) -> anyhow::Result<(String, Claims)> {
    let now = Utc::now();
    let expires = not_after.map_or(now + ttl, |limit| limit.min(now + ttl));
    let sub = match &principal {
      Principal::User { user_id, .. } => *user_id,
      Principal::Key { key_id, .. } => *key_id,
    };
    let claims = Claims {
      sub,
      jti: Uuid::now_v7(),
      iat: now.timestamp(),
      exp: expires.timestamp(),
      iat_ms: now.timestamp_millis(),
      principal,
      roles,
      must_change_password,
    };
    let token = encode(&Header::new(Algorithm::HS256), &claims, &self.encoding).context("signing token")?;
    Ok((token, claims))
  }

  /// Signature, expiry, then revocation. `None` for anything that should not be trusted.
  pub fn verify(&self, token: &str) -> Option<Claims> {
    let claims = decode::<Claims>(token, &self.decoding, &self.validation).ok()?.claims;
    let revoked = self.revoked.read().expect("revocation lock poisoned");
    let rejected = revoked.tokens.contains_key(&claims.jti)
      || claims
        .user_id()
        .is_some_and(|id| revoked.users_before_ms.get(&id).is_some_and(|b| claims.iat_ms < *b))
      || claims.key_id().is_some_and(|id| revoked.keys.contains(&id));
    (!rejected).then_some(claims)
  }

  /// Applies a revocation that the caller has already stored in the database, and tells open connections.
  pub fn apply(&self, revocation: Revocation) {
    {
      let mut revoked = self.revoked.write().expect("revocation lock poisoned");
      match &revocation {
        Revocation::Token { jti, expires_at } => {
          let now = Utc::now().timestamp();
          revoked.tokens.retain(|_, exp| *exp > now);
          revoked.tokens.insert(*jti, expires_at.timestamp());
        }
        Revocation::UserBefore { user_id, before } => {
          let entry = revoked.users_before_ms.entry(*user_id).or_insert(0);
          *entry = (*entry).max(before.timestamp_millis());
        }
        Revocation::Key(id) => {
          revoked.keys.insert(*id);
        }
      }
    }
    let _ = self.events.send(revocation);
  }

  pub fn subscribe(&self) -> broadcast::Receiver<Revocation> {
    self.events.subscribe()
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  fn state() -> AuthState {
    AuthState::from_parts(b"test-secret-test-secret-test-secret", Revoked::default())
  }

  fn user(id: Uuid) -> Principal {
    Principal::User {
      user_id: id,
      username: "u".into(),
      display_name: "U".into(),
    }
  }

  #[test]
  fn issued_tokens_verify_and_tampered_ones_do_not() {
    let s = state();
    let (token, claims) = s
      .issue(user(Uuid::now_v7()), vec![Role::Admin], false, USER_TOKEN_TTL, None)
      .unwrap();
    assert_eq!(s.verify(&token), Some(claims));
    let mut tampered = token.clone();
    tampered.pop();
    assert_eq!(s.verify(&tampered), None);
    let other = AuthState::from_parts(b"another-secret-another-secret-12", Revoked::default());
    assert_eq!(other.verify(&token), None);
  }

  #[test]
  fn expired_tokens_are_rejected() {
    let s = state();
    let (token, _) = s
      .issue(user(Uuid::now_v7()), vec![], false, TimeDelta::seconds(-120), None)
      .unwrap();
    assert_eq!(s.verify(&token), None);
  }

  #[test]
  fn key_expiry_caps_token_lifetime() {
    let s = state();
    let key = Principal::Key {
      key_id: Uuid::now_v7(),
      event_id: Uuid::now_v7(),
      label: "T1".into(),
      table_id: None,
      pod_id: None,
    };
    let limit = Utc::now() + TimeDelta::minutes(5);
    let (_, claims) = s
      .issue(key, vec![Role::Referee], false, KEY_TOKEN_TTL, Some(limit))
      .unwrap();
    assert_eq!(claims.exp, limit.timestamp());
  }

  #[test]
  fn revocations() {
    let auth = state();
    let id = Uuid::now_v7();
    let (first, first_claims) = auth.issue(user(id), vec![], false, USER_TOKEN_TTL, None).unwrap();
    let (second, _) = auth.issue(user(id), vec![], false, USER_TOKEN_TTL, None).unwrap();

    auth.apply(Revocation::Token {
      jti: first_claims.jti,
      expires_at: first_claims.expires_at(),
    });
    assert_eq!(auth.verify(&first), None);
    assert!(auth.verify(&second).is_some());

    auth.apply(Revocation::UserBefore {
      user_id: id,
      before: Utc::now() + TimeDelta::milliseconds(1),
    });
    assert_eq!(auth.verify(&second), None);
    std::thread::sleep(std::time::Duration::from_millis(5));
    let (later, _) = auth.issue(user(id), vec![], false, USER_TOKEN_TTL, None).unwrap();
    assert!(
      auth.verify(&later).is_some(),
      "tokens issued after the cutoff stay valid"
    );

    let key_id = Uuid::now_v7();
    let key = Principal::Key {
      key_id,
      event_id: Uuid::now_v7(),
      label: "T1".into(),
      table_id: None,
      pod_id: None,
    };
    let (key_token, _) = auth.issue(key, vec![], false, KEY_TOKEN_TTL, None).unwrap();
    auth.apply(Revocation::Key(key_id));
    assert_eq!(auth.verify(&key_token), None);
  }
}
