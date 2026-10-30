//! Event setup: everything an admin prepares before (and adjusts during) an event.

mod audit;
mod awards;
mod event;
mod keys;
mod layout;
mod schedule;
mod schedule_edit;
mod teams;
mod users;
mod venue;

pub use audit::SetupAudit;
pub use awards::SetupAwards;
pub use event::SetupEvent;
pub use keys::SetupKeys;
pub use layout::SetupLayout;
pub use schedule::SetupSchedule;
pub use teams::{SetupTeams, team_order};
pub use users::SetupUsers;
pub use venue::SetupVenue;
