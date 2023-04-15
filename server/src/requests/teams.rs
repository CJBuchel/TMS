use sled_extensions::bincode::Tree;

use crate::{db::db::{AccessDatabase, TmsDB}, schemas::{Team, SocketMessage}};

impl AccessDatabase for Tree<Team> {
  type Data = Team;
  type Error = ();

  fn db_get(&self, team_number: String) -> Result<Team, ()> {
    Ok(self.get(team_number.as_bytes()).unwrap().unwrap())
  }

  fn db_set(&self, team_number: String, team: Team) -> Result<Team, ()> {
    let team_update = self.update_and_fetch(team_number.as_bytes(), |t| {

      let update = match t {
        Some(_) => Option::Some(team.clone()),
        None => None,
      };

      return update;
    });

    Ok(team_update.unwrap().unwrap())
  }

  fn db_add(&self, team: Team) -> Result<Team, ()> {
    Ok(self.insert(team.team_number.as_bytes(), team.clone()).unwrap().unwrap())
  }
}