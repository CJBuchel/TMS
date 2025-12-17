use std::vec;

use anyhow::Result;
use database::DataInsert;

use crate::{core::db::get_db, generated::db::Secret};

const SECRET_TABLE_NAME: &str = "jwt_secret";
const SECRET_KEY: &str = "jwt_secret";

fn generate_secret() -> Vec<u8> {
  rand::random::<[u8; 32]>().to_vec()
}

pub trait SecretRepository {
  fn set(record: &Secret) -> Result<()>;
  fn get() -> Result<Secret>;
}

impl SecretRepository for Secret {
  fn set(record: &Secret) -> Result<()> {
    let db = get_db()?;

    let table = db.get_table(SECRET_TABLE_NAME);

    let data = DataInsert {
      id: Some(SECRET_KEY.to_string()),
      value: record.clone(),
      search_indexes: vec![],
    };

    match table.insert(data) {
      Ok(_) => {
        log::info!("JWT Secret updated in db");
      }
      Err(e) => {
        log::error!("Failed to update JWT Secret in db: {}", e);
        return Err(e);
      }
    }

    Ok(())
  }

  fn get() -> Result<Secret> {
    let db = get_db()?;

    let table = db.get_table(SECRET_TABLE_NAME);
    let record = table.get::<Secret>(SECRET_KEY)?;

    let record = if let Some(r) = record {
      r
    } else {
      log::warn!("JWT Secret not found, generating...");
      let secret_bytes = generate_secret();
      let secret = Secret { secret_bytes };
      Self::set(&secret)?;
      secret
    };

    Ok(record)
  }
}
