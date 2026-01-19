use std::pin::Pin;

use tokio_stream::{
  Stream, StreamExt,
  wrappers::{BroadcastStream, errors::BroadcastStreamRecvError},
};
use tonic::{Request, Response, Status};

use crate::{
  core::{
    events::{ChangeEvent, EVENT_BUS},
    shutdown::with_shutdown,
  },
  generated::{
    api::{StreamTeamsRequest, StreamTeamsResponse, TeamResponse, team_service_server::TeamService},
    db::Team,
  },
  modules::team::TeamRepository,
};

pub struct TeamApi;

#[tonic::async_trait]
impl TeamService for TeamApi {
  type StreamTeamsStream = Pin<Box<dyn Stream<Item = Result<StreamTeamsResponse, Status>> + Send>>;

  async fn stream_teams(
    &self,
    _request: Request<StreamTeamsRequest>,
  ) -> Result<Response<Self::StreamTeamsStream>, Status> {
    // Get all initial teams
    let initial_teams = Team::get_all()
      .map_err(|e| Status::internal(format!("Failed to get teams: {}", e)))?
      .into_iter()
      .map(|(id, team)| TeamResponse { id, team: Some(team) })
      .collect::<Vec<_>>();

    let Some(event_bus) = EVENT_BUS.get() else {
      return Err(Status::internal("Event bus not initialized"));
    };

    // Subscribe to future updates
    let rx = event_bus
      .subscribe::<Team>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to team events: {}", e)))?;

    let stream = BroadcastStream::new(rx).filter_map(|result| match result {
      Ok(event) => match event {
        ChangeEvent::Record { id, data, .. } => {
          // Single team update
          data.map(|team| Ok(StreamTeamsResponse { teams: vec![TeamResponse { id, team: Some(team) }] }))
        }
        ChangeEvent::Table => {
          // Table changed, send all teams again
          match Team::get_all() {
            Ok(teams) => {
              let responses = teams.into_iter().map(|(id, team)| TeamResponse { id, team: Some(team) }).collect();
              Some(Ok(StreamTeamsResponse { teams: responses }))
            }
            Err(e) => {
              log::error!("Failed to get all teams after table change: {}", e);
              None
            }
          }
        }
        _ => None, // Ignore other event types
      },
      Err(BroadcastStreamRecvError::Lagged(n)) => {
        log::warn!("Client lagged by {} messages", n);
        None
      }
    });

    // Combine initial + stream
    let full_stream = tokio_stream::once(Ok(StreamTeamsResponse { teams: initial_teams })).chain(stream);

    // Wrap in shutdown
    let full_stream = with_shutdown(full_stream);

    Ok(Response::new(Box::pin(full_stream)))
  }
}
