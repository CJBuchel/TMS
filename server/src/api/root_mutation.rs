use async_graphql::MergedObject;

use crate::features::TournamentConfigMutations;

#[derive(MergedObject, Default)]
pub struct RootMutation(TournamentConfigMutations);
