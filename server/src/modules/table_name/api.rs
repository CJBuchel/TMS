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
      StreamTableNamesRequest, StreamTableNamesResponse, TableNameResponse, table_name_service_server::TableNameService,
    },
    db::TableName,
  },
  modules::table_name::TableNameRepository,
};

pub struct TableNameApi;

#[tonic::async_trait]
impl TableNameService for TableNameApi {
  type StreamTableNamesStream = Pin<Box<dyn Stream<Item = Result<StreamTableNamesResponse, Status>> + Send>>;

  async fn stream_table_names(
    &self,
    _request: Request<StreamTableNamesRequest>,
  ) -> Result<Response<Self::StreamTableNamesStream>, Status> {
    // Get all initial table names
    let initial_table_names = TableName::get_all()
      .map_err(|e| Status::internal(format!("Failed to get table names: {}", e)))?
      .into_iter()
      .map(|(id, table_name)| TableNameResponse { id, table_name: Some(table_name) })
      .collect::<Vec<_>>();

    let Some(event_bus) = EVENT_BUS.get() else {
      return Err(Status::internal("Event bus not initialized"));
    };

    // Subscribe to future updates
    let rx = event_bus
      .subscribe::<TableName>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to table name events: {}", e)))?;

    let stream = BroadcastStream::new(rx).filter_map(|result| match result {
      Ok(event) => match event {
        ChangeEvent::Record { id, data, .. } => {
          // Single table name update
          data.map(|table_name| {
            Ok(StreamTableNamesResponse { table_names: vec![TableNameResponse { id, table_name: Some(table_name) }] })
          })
        }
        ChangeEvent::Table => {
          // Table changed, send all table names again
          match TableName::get_all() {
            Ok(table_names) => {
              let responses = table_names
                .into_iter()
                .map(|(id, table_name)| TableNameResponse { id, table_name: Some(table_name) })
                .collect();
              Some(Ok(StreamTableNamesResponse { table_names: responses }))
            }
            Err(e) => {
              log::error!("Failed to get all table names after table change: {}", e);
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
    let full_stream =
      tokio_stream::once(Ok(StreamTableNamesResponse { table_names: initial_table_names })).chain(stream);

    // Wrap in shutdown
    let full_stream = with_shutdown(full_stream);

    Ok(Response::new(Box::pin(full_stream)))
  }
}
