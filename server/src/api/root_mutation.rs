use async_graphql::MergedObject;

use crate::features::*;

#[derive(MergedObject, Default)]
pub struct RootMutation(TournamentConfigMutations, TeamMutations, AuthMutations);
