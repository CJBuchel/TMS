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
    api::{
      GameMatchResponse, StreamMatchesRequest, StreamMatchesResponse, game_match_service_server::GameMatchService,
    },
    db::GameMatch,
  },
  modules::game_match::GameMatchRepository,
};

pub struct GameMatchApi;

#[tonic::async_trait]
impl GameMatchService for GameMatchApi {
  type StreamMatchesStream = Pin<Box<dyn Stream<Item = Result<StreamMatchesResponse, Status>> + Send>>;

  async fn stream_matches(
    &self,
    _request: Request<StreamMatchesRequest>,
  ) -> Result<Response<Self::StreamMatchesStream>, Status> {
    // Get all initial matches
    let initial_matches = GameMatch::get_all()
      .map_err(|e| Status::internal(format!("Failed to get matches: {}", e)))?
      .into_iter()
      .map(|(id, game_match)| GameMatchResponse { id, game_match: Some(game_match) })
      .collect::<Vec<_>>();

    let Some(event_bus) = EVENT_BUS.get() else {
      return Err(Status::internal("Event bus not initialized"));
    };

    // Subscribe to future updates
    let rx = event_bus
      .subscribe::<GameMatch>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to match events: {}", e)))?;

    let stream = BroadcastStream::new(rx).filter_map(|result| match result {
      Ok(event) => match event {
        ChangeEvent::Record { id, data, .. } => {
          // Single match update
          data.map(|game_match| {
            Ok(StreamMatchesResponse { game_matches: vec![GameMatchResponse { id, game_match: Some(game_match) }] })
          })
        }
        ChangeEvent::Table => {
          // Table changed, send all matches again
          match GameMatch::get_all() {
            Ok(matches) => {
              let responses = matches
                .into_iter()
                .map(|(id, game_match)| GameMatchResponse { id, game_match: Some(game_match) })
                .collect();
              Some(Ok(StreamMatchesResponse { game_matches: responses }))
            }
            Err(e) => {
              log::error!("Failed to get all matches after table change: {}", e);
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
    let full_stream = tokio_stream::once(Ok(StreamMatchesResponse { game_matches: initial_matches })).chain(stream);

    // Wrap in shutdown
    let full_stream = with_shutdown(full_stream);

    Ok(Response::new(Box::pin(full_stream)))
  }
}
