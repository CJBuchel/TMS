use echo_tree_infra::EchoTreeRole;
pub use echo_tree_rs::core::*;
use rand::distributions::Alphanumeric;
use rand::Rng;

mod tree_names;
pub use tree_names::*;

mod backup_service;
pub use backup_service::*;

mod extensions;
pub use extensions::*;

pub use tms_infra::*;

pub struct Database {
  inner: std::sync::Arc<tokio::sync::RwLock<EchoTreeServer>>,
  backup_service_thread: Option<tokio::task::JoinHandle<()>>,
  stop_signal_sender: tokio::sync::watch::Sender<bool>,
  reset_backups_signal_sender: tokio::sync::watch::Sender<bool>,
}

pub type SharedDatabase = std::sync::Arc<tokio::sync::RwLock<Database>>;

pub trait SharedDatabaseTrait {
  fn new_instance(local_ip:String, port: u16, db_path: String, addr: [u8; 4]) -> SharedDatabase;
}

impl SharedDatabaseTrait for SharedDatabase {
  fn new_instance(local_ip: String, port: u16, db_path: String, addr: [u8; 4]) -> SharedDatabase {
    std::sync::Arc::new(tokio::sync::RwLock::new(Database::new(local_ip, port, db_path, addr)))
  }
}

impl Database {
  pub fn new(local_ip: String, port: u16, db_path: String, addr: [u8; 4]) -> Self {
    log::info!("Starting Database...");
    let config = EchoTreeServerConfig { local_ip, db_path, port, addr: addr.into() };

    let db_server = EchoTreeServer::new(config);

    let (stop_signal_sender, _) = tokio::sync::watch::channel(false);
    let (reset_backups_signal_sender, _) = tokio::sync::watch::channel(false);
    Self {
      inner: std::sync::Arc::new(tokio::sync::RwLock::new(db_server)),
      backup_service_thread: None,
      stop_signal_sender,
      reset_backups_signal_sender,
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
        let role = EchoTreeRole {
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
    self.check_insert_role("public", "", vec![TOURNAMENT_CONFIG], vec![]).await;
    self.check_insert_role("admin", &self.generate_password(), vec![":"], vec![":"]).await;
    self.check_insert_role("referee", &self.generate_password(), vec![], vec![]).await;
    self.check_insert_role("head_referee", &self.generate_password(), vec![], vec![]).await;
    self.check_insert_role("judge", &self.generate_password(), vec![], vec![]).await;
    self.check_insert_role("judge_advisor", &self.generate_password(), vec![], vec![]).await;

    // public user
    let public_user = User {
      username: "public".to_string(),
      password: "".to_string(),
      roles: vec!["public".to_string()],
    };

    match self.insert_user(public_user, None).await {
      Ok(_) => log::info!("Public user created"),
      Err(e) => log::error!("Failed to create public user: {}", e),
    }

    // insert admin user
    let admin_user = User {
      username: "admin".to_string(),
      password: "admin".to_string(),
      roles: vec!["admin".to_string()],
    };

    match self.get_user_by_username(admin_user.username.clone()).await {
      Some((_, user)) => {
        log::warn!("User already exists: {}, skipping insert...", user.username);
        return;
      }
      None => {
        match self.insert_user(admin_user, None).await {
          Ok(_) => log::info!("Admin user created"),
          Err(e) => log::error!("Failed to create admin user: {}", e),
        }
      }
    }
  }

  pub async fn create_trees(&mut self) {
    log::info!("Creating trees...");

    self.inner.read().await.add_tree_schema(TOURNAMENT_CONFIG.to_string(), TournamentConfig::to_schema()).await;
    self.inner.read().await.add_tree_schema(TEAMS.to_string(), Team::to_schema()).await;
    self.inner.read().await.add_tree_schema(ROBOT_GAME_MATCHES.to_string(), GameMatch::to_schema()).await;
    self.inner.read().await.add_tree_schema(ROBOT_GAME_TABLES.to_string(), GameTable::to_schema()).await;
    self.inner.read().await.add_tree_schema(JUDGING_SESSIONS.to_string(), JudgingSession::to_schema()).await;
    self.inner.read().await.add_tree_schema(JUDGING_PODS.to_string(), JudgingPod::to_schema()).await;
    self.inner.read().await.add_tree_schema(USERS.to_string(), User::to_schema()).await;
  }

  pub async fn get_echo_tree_routes(&self, tls: bool) -> impl warp::Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
    self.inner.read().await.get_internal_routes(tls)
  }

  pub fn get_inner(&self) -> &std::sync::Arc<tokio::sync::RwLock<EchoTreeServer>> {
    &self.inner
  }
}
