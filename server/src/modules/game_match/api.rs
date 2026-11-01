use std::pin::Pin;

use tokio_stream::{
  Stream, StreamExt,
  wrappers::{BroadcastStream, errors::BroadcastStreamRecvError},
};
use tonic::{Request, Response, Status};

use crate::{
  auth::auth_helpers::require_permission,
  core::{events::EVENT_BUS, shutdown::with_shutdown},
  generated::{
    api::{
      GameMatchResponse, GetSignatureRequest, GetSignatureResponse, StreamMatchesRequest, StreamMatchesResponse,
      SubmitSignatureRequest, SubmitSignatureResponse, game_match_service_server::GameMatchService,
    },
    common::Role,
    db::{GameMatch, TeamSignature},
  },
  modules::{game_match::GameMatchRepository, team_signature::TeamSignatureRepository},
};

/// Upper bound for a signature image (a drawn signature PNG is normally a few KB)
pub const MAX_SIGNATURE_BYTES: usize = 512 * 1024;
const PNG_MAGIC: [u8; 8] = [0x89, b'P', b'N', b'G', 0x0D, 0x0A, 0x1A, 0x0A];

/// Check that the signature payload is a non-empty, reasonably sized PNG
pub fn validate_signature_png(bytes: &[u8]) -> Result<(), Status> {
  if bytes.is_empty() {
    return Err(Status::invalid_argument("Signature is required"));
  }
  if bytes.len() > MAX_SIGNATURE_BYTES {
    return Err(Status::invalid_argument(format!("Signature too large (max {} bytes)", MAX_SIGNATURE_BYTES)));
  }
  if !bytes.starts_with(&PNG_MAGIC) {
    return Err(Status::invalid_argument("Signature must be a PNG image"));
  }
  Ok(())
}

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
        crate::core::events::ChangeEvent::Record { id, data, .. } => {
          // Single match update
          data.map(|game_match| {
            Ok(StreamMatchesResponse { game_matches: vec![GameMatchResponse { id, game_match: Some(game_match) }] })
          })
        }
        crate::core::events::ChangeEvent::Table => {
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

  async fn submit_signature(
    &self,
    request: Request<SubmitSignatureRequest>,
  ) -> Result<Response<SubmitSignatureResponse>, Status> {
    require_permission(&request, Role::Referee)?;
    let request = request.into_inner();

    validate_signature_png(&request.signature_png)?;

    let game_match = GameMatch::get(&request.match_id)
      .map_err(|e| Status::internal(format!("Failed to get match: {}", e)))?
      .ok_or_else(|| Status::not_found("Match not found"))?;

    let assignment = game_match
      .assignments
      .iter()
      .find(|a| a.table_id == request.table_id)
      .ok_or_else(|| Status::not_found("Table is not assigned in this match"))?;

    let signed_at_unix_ms = std::time::SystemTime::now()
      .duration_since(std::time::UNIX_EPOCH)
      .map(|d| u64::try_from(d.as_millis()).unwrap_or(u64::MAX))
      .unwrap_or_default();

    let signature = TeamSignature {
      match_id: request.match_id,
      table_id: request.table_id,
      team_id: assignment.team_id.clone(),
      signature_png: request.signature_png,
      signed_at_unix_ms,
    };

    TeamSignature::set(&signature).map_err(|e| Status::internal(format!("Failed to save signature: {}", e)))?;

    Ok(Response::new(SubmitSignatureResponse {}))
  }

  async fn get_signature(
    &self,
    request: Request<GetSignatureRequest>,
  ) -> Result<Response<GetSignatureResponse>, Status> {
    require_permission(&request, Role::Referee)?;
    let request = request.into_inner();

    let signature = TeamSignature::get(&request.match_id, &request.table_id)
      .map_err(|e| Status::internal(format!("Failed to get signature: {}", e)))?;

    Ok(Response::new(GetSignatureResponse { signature }))
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  fn png(len: usize) -> Vec<u8> {
    let mut v = PNG_MAGIC.to_vec();
    v.resize(len.max(PNG_MAGIC.len()), 0);
    v
  }

  #[test]
  fn rejects_empty_signature() {
    assert_eq!(validate_signature_png(&[]).unwrap_err().code(), tonic::Code::InvalidArgument);
  }

  #[test]
  fn rejects_non_png_signature() {
    assert_eq!(validate_signature_png(b"not a png at all").unwrap_err().code(), tonic::Code::InvalidArgument);
  }

  #[test]
  fn rejects_oversized_signature() {
    assert!(validate_signature_png(&png(MAX_SIGNATURE_BYTES + 1)).is_err());
  }

  #[test]
  fn accepts_valid_png_signature() {
    assert!(validate_signature_png(&png(1024)).is_ok());
    assert!(validate_signature_png(&png(MAX_SIGNATURE_BYTES)).is_ok());
  }
}
