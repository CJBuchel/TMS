use async_graphql::{MergedSubscription, OutputType, SimpleObject};

use crate::features::*;

#[derive(MergedSubscription, Default)]
pub struct RootSubscription(TournamentConfigSubscriptions, TeamSubscriptions);

#[derive(SimpleObject)]
#[graphql(concrete(name = "TournamentConfigChanged", params(TournamentConfigAPI)))]
#[graphql(concrete(name = "TeamChanged", params(TeamAPI)))]
pub struct RecordChangedAPI<T: OutputType> {
  pub id: String,
  pub record: Option<T>,
}

impl<T: OutputType> RecordChangedAPI<T> {
  pub fn new(id: String, record: Option<T>) -> Self {
    Self { id, record }
  }
}
