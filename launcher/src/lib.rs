pub mod gui;
pub mod logging;
pub mod qr_code;

#[derive(Debug, Clone, PartialEq)]
pub enum ServerState {
  Stopped,
  Running,
  Error(String),
}

pub enum GuiMessage {
  StartServer(server::TmsConfig),
  StopServer,
  Exit,
}
