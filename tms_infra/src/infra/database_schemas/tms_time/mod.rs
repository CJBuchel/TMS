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

  
  fn compare_to(&self, other: Self) -> i32;

  
  fn duration(&self) -> TmsDuration;

  
  fn difference(&self, other: Self) -> TmsDuration;

  
  fn is_after(&self, other: Self) -> bool;

  
  fn is_before(&self, other: Self) -> bool;

  
  fn is_same_moment(&self, other: Self) -> bool;

  
  fn to_string(&self) -> String;

  
  fn add_duration(&self, duration: TmsDuration) -> Self;
}