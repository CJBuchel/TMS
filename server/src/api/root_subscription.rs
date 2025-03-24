use async_graphql::MergedSubscription;

use crate::features::TournamentConfigSubscriptions;

#[derive(MergedSubscription, Default)]
pub struct RootSubscription(TournamentConfigSubscriptions);
