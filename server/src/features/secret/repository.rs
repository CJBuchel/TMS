use super::Secret;

const JWT_SECRET_KEY: &str = "jwt_secret";

pub trait SecretRepository {
  async fn update(secret: Vec<u8>) -> anyhow::Result<Vec<u8>>;
  async fn get() -> anyhow::Result<Vec<u8>>;
}

impl SecretRepository for Secret {
  async fn update(secret: Vec<u8>) -> anyhow::Result<Vec<u8>> {
    let db = match crate::core::db::DB.get() {
      Some(db) => db,
      None => {
        log::warn!("DB not initialized");
        return Err(anyhow::anyhow!("DB not initialized"));
      }
    };

    let table = db.get_table::<Secret>().await?;
    let record = Secret(secret.clone());
    table.insert(Some(&JWT_SECRET_KEY.to_string()), &record)?;

    Ok(secret)
  }

  async fn get() -> anyhow::Result<Vec<u8>> {
    let db = match crate::core::db::DB.get() {
      Some(db) => db,
      None => {
        log::warn!("DB not initialized");
        return Err(anyhow::anyhow!("DB not initialized"));
      }
    };

    let table = db.get_table::<Secret>().await?;
    let record = table.get(&JWT_SECRET_KEY.to_string())?;

    let record = match record {
      Some(record) => record,
      None => {
        log::warn!("Secret not found, generating...");
        let secret = Secret::default();
        table.insert(Some(&JWT_SECRET_KEY.to_string()), &secret)?;
        secret
      }
    };

    Ok(record.0)
  }
}
