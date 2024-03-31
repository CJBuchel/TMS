
use echo_tree_rs::core::{EchoTreeServer, EchoTreeServerConfig, SchemaUtil};
use schema::{DataSchemeExtensions, Team, TournamentConfig};
use rand::Rng;
use rand::distributions::Alphanumeric;

pub struct Database {
  inner: EchoTreeServer,
}

impl Database {
  pub fn new(port: u16, db_path: String, addr: [u8; 4]) -> Self {
    log::info!("Starting Database...");
    let config = EchoTreeServerConfig {
      db_path,
      port,
      addr: addr.into(),
    };

    let db_server = EchoTreeServer::new(config);

    Self {
      inner: db_server,
    }
  }

  fn generate_password(&self) -> String {
    rand::thread_rng()
    .sample_iter(&Alphanumeric)
    .take(30)
    .map(char::from)
    .collect()
  }

  async fn check_insert_role(&self, role: &str, password: &str, read_echo_trees: Vec<&str>, read_write_echo_trees: Vec<&str>) {
    match self.get_inner().get_role_manager().await.get_role(role.to_string()) {
      Some(_) => {
        log::warn!("Role already exist: {}", role);
        return;
      },
      None => {
        let role = echo_tree_rs::protocol::schemas::Role {
          role_id: role.to_string(),
          password: password.to_string(),
          read_echo_trees: read_echo_trees.iter().map(|x| x.to_string()).collect(),
          read_write_echo_trees: read_write_echo_trees.iter().map(|x| x.to_string()).collect(),
        };
        self.inner.get_role_manager().await.insert_role(role);
      },
    }
  }

  pub async fn create_roles(&mut self) {
    log::info!("Creating roles...");

    // :public
    // :admin
    // :referee
    // :head_referee
    // :judge
    // :judge_advisor

    // Future me, maybe make passwords auto generated, then have a login method which verifies the user and gives back the generated password for their role.
    self.check_insert_role("public", "public", vec![], vec![]).await;
    self.check_insert_role("admin", &self.generate_password(), vec![], vec![":"]).await;
    self.check_insert_role("referee", &self.generate_password(), vec![], vec![]).await;
    self.check_insert_role("head_referee", &self.generate_password(), vec![], vec![]).await;
    self.check_insert_role("judge", &self.generate_password(), vec![], vec![]).await;
    self.check_insert_role("judge_advisor", &self.generate_password(), vec![], vec![]).await;
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

  pub fn get_inner(&self) -> &EchoTreeServer {
    &self.inner
  }
}
