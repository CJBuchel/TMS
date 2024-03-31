
use echo_tree_rs::core::{EchoTreeServer, EchoTreeServerConfig, SchemaUtil};
use schema::{DataSchemeExtensions, Team, TournamentConfig};

pub struct Database {
  inner: EchoTreeServer,
}

impl Database {
  pub fn new(port: u16, db_path: String) -> Self {
    log::info!("Starting Database...");
    let config = EchoTreeServerConfig {
      db_path,
      port,
      addr: [0,0,0,0].into(),
    };

    let db_server = EchoTreeServer::new(config);

    Self {
      inner: db_server,
    }
  }

  pub async fn create_trees(&mut self) {
    log::info!("Creating trees...");

    // :tournament_config
    // :teams

    // :robot_game:matches
    // :robot_game:game_scores
    // :robot_game:tables

    // :judging:core_values_scores
    // :judging:innovation_project_scores
    // :judging:robot_design_scores
    // :judging:pods


    self.inner.add_tree_schema(":tournament_config".to_string(), TournamentConfig::get_schema()).await;
    self.inner.add_tree_schema(":teams".to_string(), Team::get_schema()).await;
  }
}
