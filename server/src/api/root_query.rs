use async_graphql::MergedObject;

use crate::features::*;

#[derive(MergedObject, Default)]
pub struct RootQuery(TournamentConfigQueries, TeamQueries);
