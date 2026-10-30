//! Domain types shared by the TMS server and the web client. No IO, compiles to WASM.

pub mod access_key;
pub mod deliberation;
pub mod dto;
pub mod game;
pub mod judging;
pub mod model;
pub mod queue;
pub mod role;
pub mod topic;
pub mod validation;
pub mod ws;

pub use role::Role;
pub use topic::Topic;
