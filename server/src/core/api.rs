use async_graphql::{EmptyMutation, EmptySubscription, Schema};

use crate::api::RootQuery;

pub struct TmsApi {
  enable_playground: bool,
}

impl TmsApi {
  pub fn new(enable_playground: bool) -> Self {
    TmsApi { enable_playground }
  }

  pub fn run(&self) {
    let schema = Schema::build(RootQuery, EmptyMutation, EmptySubscription).finish();
  }
}
