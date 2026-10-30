//! Schedules as TMS needs them: teams, tables, pods, matches with team slots, judging sessions with team slots.
//!
//! - `tiab` reads the FIRST Australia Tournament-in-a-Box / FLL Scheduler CSV ("Version Number,1").
//! - `resolve` turns its day labels and local times into dates and UTC instants for an event.
//! - `generate` builds a schedule from the event's teams, tables, pods and times.
//! - `view` hands any of these to the schedule checks in `tms_core::validation`.
//! - `write` writes a schedule back out as a Tournament-in-a-Box CSV.

pub mod generate;
pub mod resolve;
pub mod tiab;
pub mod view;
pub mod write;

pub use generate::{GenerateError, GenerateInput, Generated, generate};
pub use resolve::{ResolvedMatch, ResolvedSchedule, ResolvedSession, resolve};
pub use tiab::{TiabFile, TiabTeam, parse};
