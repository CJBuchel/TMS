pub use echo_tree_rs::core::{EchoTreeServer, EchoTreeServerConfig, SchemaUtil, TreeManager};
use rand::distributions::Alphanumeric;
use rand::Rng;

mod backup_service;
pub use backup_service::*;

pub use tms_infra::*;
// pub use database_schema::;

pub struct Database {
  inner: std::sync::Arc<tokio::sync::RwLock<EchoTreeServer>>,
  backup_service_thread: Option<tokio::task::JoinHandle<()>>,
  stop_signal_sender: tokio::sync::watch::Sender<bool>,
}

pub type SharedDatabase = std::sync::Arc<tokio::sync::RwLock<Database>>;

pub trait SharedDatabaseTrait {
  fn new_instance(port: u16, db_path: String, addr: [u8; 4]) -> SharedDatabase;
}

impl SharedDatabaseTrait for SharedDatabase {
  fn new_instance(port: u16, db_path: String, addr: [u8; 4]) -> SharedDatabase {
    std::sync::Arc::new(tokio::sync::RwLock::new(Database::new(port, db_path, addr)))
  }
}

impl Database {
  pub fn new(port: u16, db_path: String, addr: [u8; 4]) -> Self {
    log::info!("Starting Database...");
    let config = EchoTreeServerConfig { db_path, port, addr: addr.into() };

    let db_server = EchoTreeServer::new(config);

    let (stop_signal_sender, _) = tokio::sync::watch::channel(false);
    Self {
      inner: std::sync::Arc::new(tokio::sync::RwLock::new(db_server)),
      backup_service_thread: None,
      stop_signal_sender,
    }
  }

  fn generate_password(&self) -> String {
    rand::thread_rng().sample_iter(&Alphanumeric).take(30).map(char::from).collect()
  }

  async fn check_insert_role(&self, role: &str, password: &str, read_echo_trees: Vec<&str>, read_write_echo_trees: Vec<&str>) {
    match self.inner.read().await.get_role_manager().await.get_role(role.to_string()) {
      Some(_) => {
        log::warn!("Role already exist: {}", role);
        return;
      }
      None => {
        let role = echo_tree_rs::protocol::schemas::Role {
          role_id: role.to_string(),
          password: password.to_string(),
          read_echo_trees: read_echo_trees.iter().map(|x| x.to_string()).collect(),
          read_write_echo_trees: read_write_echo_trees.iter().map(|x| x.to_string()).collect(),
        };
        self.inner.read().await.get_role_manager().await.insert_role(role);
      }
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

    // :tournament:config
    // :teams
    // :users

    // :robot_game:matches
    // :robot_game:game_scores
    // :robot_game:tables

    // :judging:core_value_scores
    // :judging:innovation_project_scores
    // :judging:robot_design_scores
    // :judging:pods

    self.inner.read().await.add_tree_schema(":tournament:config".to_string(), TournamentConfig::to_schema()).await;
    self.inner.read().await.add_tree_schema(":teams".to_string(), Team::to_schema()).await;
    self.inner.read().await.add_tree_schema(":users".to_string(), User::to_schema()).await;
  }

  pub async fn get_echo_tree_routes(&self, tls: bool) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
    self.inner.read().await.get_internal_routes(tls)
  }

  pub fn get_inner(&self) -> &std::sync::Arc<tokio::sync::RwLock<EchoTreeServer>> {
    &self.inner
  }
}
