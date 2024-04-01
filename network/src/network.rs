use database::SharedDatabase;


pub struct Network {
  db: SharedDatabase,
}

impl Network {
  pub fn new(db: SharedDatabase) -> Self {
    Self {
      db,
    }
  }

  
}