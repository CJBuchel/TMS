//! Failed-login throttling per client address. In memory: a restart clears it, which is fine for a LAN server.

use std::collections::HashMap;
use std::net::IpAddr;
use std::sync::Mutex;
use std::time::{Duration, Instant};

use crate::error::ApiError;

pub const WINDOW: Duration = Duration::from_mins(5);
pub const MAX_FAILURES: u32 = 10;

#[derive(Default)]
pub struct LoginLimiter {
  failures: Mutex<HashMap<IpAddr, (u32, Instant)>>,
}

impl LoginLimiter {
  /// Refuses an attempt once an address has failed `MAX_FAILURES` times within `WINDOW`.
  pub fn check(&self, ip: IpAddr) -> Result<(), ApiError> {
    let map = self.failures.lock().expect("limiter lock poisoned");
    match map.get(&ip) {
      Some((count, since)) if *count >= MAX_FAILURES && since.elapsed() < WINDOW => Err(ApiError::RateLimited),
      _ => Ok(()),
    }
  }

  pub fn failed(&self, ip: IpAddr) {
    let mut map = self.failures.lock().expect("limiter lock poisoned");
    map.retain(|_, (_, since)| since.elapsed() < WINDOW);
    let entry = map.entry(ip).or_insert((0, Instant::now()));
    entry.0 += 1;
  }

  pub fn succeeded(&self, ip: IpAddr) {
    self.failures.lock().expect("limiter lock poisoned").remove(&ip);
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn blocks_after_max_failures_and_success_clears() {
    let limiter = LoginLimiter::default();
    let ip: IpAddr = "10.0.0.5".parse().unwrap();
    let other: IpAddr = "10.0.0.6".parse().unwrap();
    for _ in 0..MAX_FAILURES {
      assert!(limiter.check(ip).is_ok());
      limiter.failed(ip);
    }
    assert!(matches!(limiter.check(ip), Err(ApiError::RateLimited)));
    assert!(limiter.check(other).is_ok());
    limiter.succeeded(ip);
    assert!(limiter.check(ip).is_ok());
  }
}
