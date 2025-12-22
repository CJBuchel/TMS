use std::{pin::Pin, time::Duration};

use tokio_stream::Stream;
use tonic::{Request, Response, Status};

use crate::{
  core::shutdown::with_shutdown,
  generated::api::{GetHealthRequest, GetHealthResponse, health_service_server::HealthService},
};

pub struct HealthApi;

#[tonic::async_trait]
impl HealthService for HealthApi {
  type StreamHealthStream = Pin<Box<dyn Stream<Item = Result<GetHealthResponse, Status>> + Send>>;

  async fn get_health(&self, _: Request<GetHealthRequest>) -> Result<Response<GetHealthResponse>, Status> {
    Ok(Response::new(GetHealthResponse {}))
  }

  async fn stream_health(&self, _: Request<GetHealthRequest>) -> Result<Response<Self::StreamHealthStream>, Status> {
    let mut interval = tokio::time::interval(Duration::from_secs(15));

    let stream = async_stream::stream! {
      loop {
        interval.tick().await;
        yield Ok(GetHealthResponse {});
      }
    };

    let stream = with_shutdown(stream);
    Ok(Response::new(Box::pin(stream)))
  }
}
