pub mod errors;
pub use errors::*;

pub mod register_requests;
pub use register_requests::*;

pub mod login_requests;
pub use login_requests::*;

pub mod tournament_config_requests;
pub use tournament_config_requests::*;

pub mod socket_protocol;
pub use socket_protocol::*;

pub mod robot_game_requests;
pub use robot_game_requests::*;

pub mod teams_requests;
pub use teams_requests::*;