#![forbid(unsafe_code)]
mod config;
pub use config::*;

pub mod core;
pub mod generated;
pub mod modules;
