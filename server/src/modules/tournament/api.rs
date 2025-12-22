use std::pin::Pin;
use tokio_stream::{
  Stream, StreamExt,
  wrappers::{BroadcastStream, errors::BroadcastStreamRecvError},
};
use tonic::{Request, Response, Result, Status};

use crate::{
  auth::auth_helpers::require_permission,
  core::{events::EVENT_BUS, shutdown::with_shutdown},
  generated::{
    api::{
      DeleteTournamentRequest, DeleteTournamentResponse, GetTournamentRequest, GetTournamentResponse,
      SetTournamentRequest, SetTournamentResponse, StreamTournamentRequest, StreamTournamentResponse,
      tournament_service_server::TournamentService,
    },
    common::Role,
    db::{GameMatch, JudgingSession, PodName, TableName, Team, Tournament, User},
  },
  modules::{
    game_match::GameMatchRepository, judging_session::JudgingSessionRepository, pod_name::PodRepository,
    table_name::TableRepository, team::TeamRepository, tournament::TournamentRepository, user::UserRepository,
  },
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

    let Some(mut request) = request.tournament else {
      return Err(Status::invalid_argument("Tournament is required"));
    };

    request.bootstrapped = true;

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

    let Some(event_bus) = EVENT_BUS.get() else {
      return Err(Status::internal("Event bus not initialized"));
    };

    // Subscribe to future updates
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

    // Wrap in shutdown
    let full_stream = with_shutdown(full_stream);

    Ok(Response::new(Box::pin(full_stream)))
  }

  async fn delete_tournament(
    &self,
    request: Request<DeleteTournamentRequest>,
  ) -> Result<Response<DeleteTournamentResponse>, Status> {
    require_permission(&request, Role::Admin)?;

    // Clear all tournament-related data
    Tournament::clear().map_err(|e| Status::internal(format!("Failed to clear tournament data: {}", e)))?;
    User::clear().map_err(|e| Status::internal(format!("Failed to clear user data: {}", e)))?;
    Team::clear().map_err(|e| Status::internal(format!("Failed to clear team data: {}", e)))?;
    GameMatch::clear().map_err(|e| Status::internal(format!("Failed to clear match data: {}", e)))?;
    TableName::clear().map_err(|e| Status::internal(format!("Failed to clear table name data: {}", e)))?;
    PodName::clear().map_err(|e| Status::internal(format!("Failed to clear pod name data: {}", e)))?;
    JudgingSession::clear().map_err(|e| Status::internal(format!("Failed to clear judging session data: {}", e)))?;

    log::info!("All tournament data cleared");

    Ok(Response::new(DeleteTournamentResponse {}))
  }
}
