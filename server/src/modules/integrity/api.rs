use std::pin::Pin;

use tokio_stream::{Stream, StreamExt, wrappers::BroadcastStream};
use tonic::{Request, Response, Result, Status};

use crate::{
  core::{
    events::{ChangeEvent, EVENT_BUS},
    shutdown::with_shutdown,
  },
  generated::{
    api::{
      GetIntegrityMessagesRequest, GetIntegrityMessagesResponse, StreamIntegrityMessagesRequest,
      StreamIntegrityMessagesResponse, integrity_service_server::IntegrityService,
    },
    common::IntegrityMessage,
  },
  modules::integrity::IntegrityChecker,
};

pub struct IntegrityApi;

#[tonic::async_trait]
impl IntegrityService for IntegrityApi {
  type StreamIntegrityMessagesStream =
    Pin<Box<dyn Stream<Item = Result<StreamIntegrityMessagesResponse, Status>> + Send>>;

  async fn get_integrity_messages(
    &self,
    _: Request<GetIntegrityMessagesRequest>,
  ) -> Result<Response<GetIntegrityMessagesResponse>, Status> {
    // Get cached messages
    let messages = IntegrityChecker::get_cached();

    let response = GetIntegrityMessagesResponse { messages };

    Ok(Response::new(response))
  }

  async fn stream_integrity_messages(
    &self,
    _: Request<StreamIntegrityMessagesRequest>,
  ) -> Result<Response<Self::StreamIntegrityMessagesStream>, Status> {
    // Get initial cached messages
    let initial = IntegrityChecker::get_cached();

    let Some(event_bus) = EVENT_BUS.get() else {
      return Err(Status::internal("Event bus not initialized"));
    };

    // Subscribe to future updates
    let rx = event_bus
      .subscribe::<Vec<IntegrityMessage>>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to integrity message events: {}", e)))?;

    let stream = BroadcastStream::new(rx).filter_map(|result| match result {
      Ok(event) => match event {
        ChangeEvent::IntegrityUpdate { data } => Some(Ok(StreamIntegrityMessagesResponse { messages: data })),
        _ => None, // Ignore Record, Table, and Message events
      },
      Err(tokio_stream::wrappers::errors::BroadcastStreamRecvError::Lagged(n)) => {
        // Client fell behind, they'll get next update
        log::warn!("Client lagged by {} integrity messages", n);
        None
      }
    });

    // Combine initial + stream
    let full_stream = tokio_stream::once(Ok(StreamIntegrityMessagesResponse { messages: initial })).chain(stream);

    // Wrap in shutdown
    let full_stream = with_shutdown(full_stream);

    Ok(Response::new(Box::pin(full_stream)))
  }
}
