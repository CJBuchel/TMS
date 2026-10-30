//! Password hashing (argon2id), random secrets and access keys. Access keys are stored only as SHA-256 hashes.

use argon2::password_hash::SaltString;
use argon2::password_hash::rand_core::OsRng;
use argon2::{Argon2, PasswordHash, PasswordHasher, PasswordVerifier};
use rand::Rng;
use sha2::{Digest, Sha256};
use tms_core::Role;
use tms_core::access_key::{self, ALPHABET, SECRET_LEN};

/// Hash compared against when the username does not exist, so unknown usernames cost the same time as wrong passwords.
pub static DUMMY_HASH: std::sync::LazyLock<String> =
  std::sync::LazyLock::new(|| hash_password(&new_token()).expect("hashing a random string cannot fail"));

pub fn hash_password(password: &str) -> anyhow::Result<String> {
  let salt = SaltString::generate(&mut OsRng);
  Argon2::default()
    .hash_password(password.as_bytes(), &salt)
    .map(|h| h.to_string())
    .map_err(|e| anyhow::anyhow!("hashing password: {e}"))
}

pub fn verify_password(password: &str, hash: &str) -> bool {
  PasswordHash::new(hash).is_ok_and(|h| Argon2::default().verify_password(password.as_bytes(), &h).is_ok())
}

/// Argon2 is deliberately slow, so it runs off the async worker threads.
pub async fn verify_password_blocking(password: String, hash: String) -> bool {
  tokio::task::spawn_blocking(move || verify_password(&password, &hash))
    .await
    .unwrap_or(false)
}

pub async fn hash_password_blocking(password: String) -> anyhow::Result<String> {
  tokio::task::spawn_blocking(move || hash_password(&password)).await?
}

/// 32 random bytes as hex, for one-time passwords and other generated secrets.
pub fn new_token() -> String {
  hex::encode(rand::random::<[u8; 32]>())
}

pub fn sha256(text: &str) -> Vec<u8> {
  Sha256::digest(text.as_bytes()).to_vec()
}

pub fn new_access_key(role: Role) -> String {
  let mut rng = rand::rng();
  let secret: String = (0..SECRET_LEN)
    .map(|_| char::from(ALPHABET[rng.random_range(0..ALPHABET.len())]))
    .collect();
  access_key::format(role, &secret)
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn password_round_trip() {
    let h = hash_password("correct horse").unwrap();
    assert!(verify_password("correct horse", &h));
    assert!(!verify_password("wrong", &h));
  }

  #[test]
  fn dummy_hash_parses_and_never_matches_empty() {
    assert!(PasswordHash::new(&DUMMY_HASH).is_ok());
    assert!(!verify_password("", &DUMMY_HASH));
  }

  #[test]
  fn generated_keys_parse() {
    for role in Role::ALL {
      let key = new_access_key(role);
      let parsed = access_key::parse(&key).unwrap();
      assert_eq!(parsed.role, role);
      assert_eq!(parsed.normalized, key);
    }
  }
}
