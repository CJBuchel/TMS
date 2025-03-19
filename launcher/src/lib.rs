pub mod gui;
pub mod logging;

#[derive(Debug, Clone, PartialEq)]
pub enum ServerState {
  Stopped,
  Running,
  Error(String),
}

#[derive(Debug, Clone)]
pub enum GuiMessage {
  StartServer(server::TmsConfig),
  StopServer,
  Exit,
}
