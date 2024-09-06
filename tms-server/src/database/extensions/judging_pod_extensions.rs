use tms_infra::*;

use crate::database::{Database, JUDGING_PODS};
pub use echo_tree_rs::core::*;
use uuid::Uuid;

#[async_trait::async_trait]
pub trait JudgingPodExtensions {
  async fn get_judging_pod(&self, judging_pod_id: String) -> Option<String>;
  async fn get_judging_pod_by_name(&self, name: String) -> Option<(String, String)>;
  async fn insert_judging_pod(&self, judging_pod: String, judging_pod_id: Option<String>) -> Result<(), String>;
  async fn remove_judging_pod(&self, judging_pod_id: String) -> Result<(), String>;
}

#[async_trait::async_trait]
impl JudgingPodExtensions for Database {
  async fn get_judging_pod(&self, judging_pod_id: String) -> Option<String> {
    let tree = self.inner.read().await.get_tree(JUDGING_PODS.to_string()).await;
    let judging_pod = tree.get(&judging_pod_id).cloned();

    match judging_pod {
      Some(judging_pod) => Some(JudgingPod::from_json_string(&judging_pod).pod_name),
      None => None,
    }
  }

  async fn get_judging_pod_by_name(&self, name: String) -> Option<(String, String)> {
    let tree = self.inner.read().await.get_tree(JUDGING_PODS.to_string()).await;
    let judging_pod = tree.iter().find_map(|(id, judging_pod)| {
      let judging_pod = JudgingPod::from_json_string(judging_pod);
      if judging_pod.pod_name == name {
        Some((id.clone(), judging_pod))
      } else {
        None
      }
    });

    match judging_pod {
      Some((id, judging_pod)) => Some((id, judging_pod.pod_name)),
      None => None,
    }
  }

  async fn insert_judging_pod(&self, judging_pod: String, judging_pod_id: Option<String>) -> Result<(), String> {
    // check if judging_pod already exists (using id if provided, otherwise using number)
    let existing_judging_pod: Option<(String, String)> = match judging_pod_id {
      Some(judging_pod_id) => self.get_judging_pod(judging_pod_id.clone()).await.map(|judging_pod| (judging_pod_id, judging_pod)),
      None => self.get_judging_pod_by_name(judging_pod.clone()).await,
    };

    match existing_judging_pod {
      Some((judging_pod_id, _)) => {
        log::warn!("JudgingPod already exists: {}, overwriting with insert...", judging_pod_id);
        let judging_pod = JudgingPod { pod_name: judging_pod };
        self.inner.write().await.insert_entry(JUDGING_PODS.to_string(), judging_pod_id, judging_pod.to_json_string()).await;
        Ok(())
      }
      None => {
        let judging_pod = JudgingPod { pod_name: judging_pod };
        self.inner.write().await.insert_entry(JUDGING_PODS.to_string(), Uuid::new_v4().to_string(), judging_pod.to_json_string()).await;
        Ok(())
      }
    }
  }

  async fn remove_judging_pod(&self, judging_pod_id: String) -> Result<(), String> {
    let tree = self.inner.read().await.get_tree(JUDGING_PODS.to_string()).await;
    let judging_pod = tree.get(&judging_pod_id).cloned();

    match judging_pod {
      Some(_) => {
        self.inner.write().await.remove_entry(JUDGING_PODS.to_string(), judging_pod_id).await;
        Ok(())
      }
      None => Err("JudgingPod does not exist".to_string()),
    }
  }
}
