use tms_infra::TournamentBlueprint;
use uuid::Uuid;

use crate::database::*;
pub use echo_tree_rs::core::*;
use tms_infra::*;


#[async_trait::async_trait]
pub trait TournamentBlueprintExtensions {
  async fn get_blueprint(&self, blueprint_id: String) -> Option<TournamentBlueprint>;
  async fn get_blueprint_by_title(&self, title: String) -> Option<(String, TournamentBlueprint)>;
  async fn get_blueprint_titles(&self) -> Vec<String>;
  async fn insert_blueprint(&self, blueprint: TournamentBlueprint, blueprint_id: Option<String>) -> Result<(), String>;
  async fn remove_blueprint(&self, blueprint_id: String) -> Result<(), String>;
}

#[async_trait::async_trait]
impl TournamentBlueprintExtensions for Database {
  async fn get_blueprint(&self, blueprint_id: String) -> Option<TournamentBlueprint> {
    let tree = self.inner.read().await.get_tree(TOURNAMENT_BLUEPRINT.to_string()).await;
    let blueprint = tree.get(&blueprint_id).cloned();

    match blueprint {
      Some(blueprint) => {
        Some(TournamentBlueprint::from_json_string(&blueprint))
      }
      None => None,
    }
  }

  async fn get_blueprint_by_title(&self, title: String) -> Option<(String, TournamentBlueprint)> {
    let tree = self.inner.read().await.get_tree(TOURNAMENT_BLUEPRINT.to_string()).await;
    let blueprint = tree.iter().find_map(|(id, blueprint)| {
      let blueprint = TournamentBlueprint::from_json_string(blueprint);
      if blueprint.title == title {
        Some((id.clone(), blueprint))
      } else {
        None
      }
    });

    match blueprint {
      Some((id, blueprint)) => {
        Some((id, blueprint))
      }
      None => None,
    }
  }

  async fn get_blueprint_titles(&self) -> Vec<String> {
    let tree = self.inner.read().await.get_tree(TOURNAMENT_BLUEPRINT.to_string()).await;
    let titles = tree.iter().map(|(_, blueprint)| {
      let blueprint = TournamentBlueprint::from_json_string(blueprint);
      blueprint.title
    }).collect();

    titles
  }

  async fn insert_blueprint(&self, blueprint: TournamentBlueprint, blueprint_id: Option<String>) -> Result<(), String> {
    // check if blueprint already exists (using id if provided, otherwise using title)
    let existing_blueprint: Option<(String, TournamentBlueprint)> = match blueprint_id {
      Some(blueprint_id) => self.get_blueprint(blueprint_id.clone()).await.map(|blueprint| (blueprint_id, blueprint)),
      None => self.get_blueprint_by_title(blueprint.clone().title).await,
    }; 

    match existing_blueprint {
      Some((blueprint_id, _)) => {
        log::warn!("Blueprint already exists: {}, overwriting with insert...", blueprint_id);
        self.inner.write().await.insert_entry(TOURNAMENT_BLUEPRINT.to_string(), blueprint_id, blueprint.to_json_string()).await;
        Ok(())
      },
      None => {
        self.inner.write().await.insert_entry(TOURNAMENT_BLUEPRINT.to_string(), Uuid::new_v4().to_string(), blueprint.to_json_string()).await;
        Ok(())
      }
    }
  }

  async fn remove_blueprint(&self, blueprint_id: String) -> Result<(), String> {
    let tree = self.inner.read().await.get_tree(TOURNAMENT_BLUEPRINT.to_string()).await;
    let blueprint = tree.get(&blueprint_id).cloned();

    match blueprint {
      Some(_) => {
        self.inner.write().await.remove_entry(TOURNAMENT_BLUEPRINT.to_string(), blueprint_id).await;
        Ok(())
      }
      None => Err("Blueprint does not exist".to_string())
    }
  }
}