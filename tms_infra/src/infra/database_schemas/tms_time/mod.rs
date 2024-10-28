pub mod tms_duration;
pub use tms_duration::*;

pub mod tms_date;
pub use tms_date::*;

pub mod tms_time;
pub use tms_time::*;

pub mod tms_date_time;
pub use tms_date_time::*;

// generic trait applied to all time-based types
pub trait TmsTimeBased {
  fn now() -> Self;

  #[flutter_rust_bridge::frb(sync)]
  fn compare_to(&self, other: Self) -> i32;

  #[flutter_rust_bridge::frb(sync)]
  fn duration(&self) -> TmsDuration;

  #[flutter_rust_bridge::frb(sync)]
  fn difference(&self, other: Self) -> TmsDuration;

  #[flutter_rust_bridge::frb(sync)]
  fn is_after(&self, other: Self) -> bool;

  #[flutter_rust_bridge::frb(sync)]
  fn is_before(&self, other: Self) -> bool;

  #[flutter_rust_bridge::frb(sync)]
  fn is_same_moment(&self, other: Self) -> bool;

  #[flutter_rust_bridge::frb(sync)]
  fn to_string(&self) -> String;

  #[flutter_rust_bridge::frb(sync)]
  fn add_duration(&self, duration: TmsDuration) -> Self;
}