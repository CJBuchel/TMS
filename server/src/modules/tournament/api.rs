use std::pin::Pin;
use tokio_stream::{
  Stream, StreamExt,
  wrappers::{BroadcastStream, errors::BroadcastStreamRecvError},
};
use tonic::{Request, Response, Result, Status};

use crate::{
  core::{auth_helpers::require_permission, events::EVENT_BUS},
  generated::{
    api::{
      GetTournamentRequest, GetTournamentResponse, SetTournamentRequest, SetTournamentResponse,
      StreamTournamentRequest, StreamTournamentResponse, tournament_service_server::TournamentService,
    },
    common::Role,
    db::Tournament,
  },
  modules::tournament::TournamentRepository,
};

pub struct TournamentApi;

#[tonic::async_trait]
impl TournamentService for TournamentApi {
  type StreamTournamentStream = Pin<Box<dyn Stream<Item = Result<StreamTournamentResponse, Status>> + Send>>;

  async fn get_tournament(&self, _: Request<GetTournamentRequest>) -> Result<Response<GetTournamentResponse>, Status> {
    let response = GetTournamentResponse {
      tournament: Some(Tournament::get()),
    };

    Ok(Response::new(response))
  }

  async fn set_tournament(
    &self,
    request: Request<SetTournamentRequest>,
  ) -> Result<Response<SetTournamentResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let request = request.into_inner();

    let Some(request) = request.tournament else {
      return Err(Status::invalid_argument("Tournament is required"));
    };

    match Tournament::set(&request) {
      Ok(()) => Ok(Response::new(SetTournamentResponse {})),
      Err(e) => Err(Status::internal(e.to_string())),
    }
  }

  async fn stream_tournament(
    &self,
    _: Request<StreamTournamentRequest>,
  ) -> Result<Response<Self::StreamTournamentStream>, Status> {
    let initial = Tournament::get();

    // Subscribe to future updates
    let Some(event_bus) = EVENT_BUS.get() else {
      return Err(Status::internal("Event bus not initialized"));
    };

    let rx = event_bus
      .subscribe::<Tournament>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to tournament events: {}", e)))?;

    let stream = BroadcastStream::new(rx).filter_map(|result| match result {
      Ok(event) => Some(Ok(StreamTournamentResponse { tournament: event.data })),
      Err(BroadcastStreamRecvError::Lagged(n)) => {
        // Client fell behind, they'll get next update
        log::warn!("Client lagged by {} messages", n);
        None
      }
    });

    // Combine initial + stream
    let full_stream = tokio_stream::once(Ok(StreamTournamentResponse {
      tournament: Some(initial),
    }))
    .chain(stream);

    Ok(Response::new(Box::pin(full_stream)))
  }
}
