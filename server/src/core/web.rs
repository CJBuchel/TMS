use std::net::IpAddr;
use tokio::net::TcpListener;

use anyhow::Result;
use async_graphql::{http::GraphiQLSource, Schema};
use async_graphql_axum::{GraphQLRequest, GraphQLResponse, GraphQLSubscription};
use axum::{
  extract::State,
  http::HeaderMap,
  response::{self, IntoResponse},
  routing::{get, post},
  Router,
};

use crate::api::{RootMutation, RootQuery, RootSubscription};

const GRAPHQL_ENDPOINT: &str = "/graphql";
const GRAPHQL_SUBSCRIPTION_ENDPOINT: &str = "/graphql/subscriptions";
const GRAPHQL_PLAYGROUND_ENDPOINT: &str = "/playground";

pub type TmsSchema = Schema<RootQuery, RootMutation, RootSubscription>;

pub struct TmsWeb {
  addr: IpAddr,
  port: u16,
  enable_playground: bool,
}

async fn playground_handler() -> impl IntoResponse {
  response::Html(
    GraphiQLSource::build()
      .endpoint(GRAPHQL_ENDPOINT)
      .subscription_endpoint(GRAPHQL_SUBSCRIPTION_ENDPOINT)
      .finish(),
  )
}

async fn graphql_handler(State(schema): State<TmsSchema>, _headers: HeaderMap, req: GraphQLRequest) -> GraphQLResponse {
  let req = req.into_inner();
  schema.execute(req).await.into()
}

impl TmsWeb {
  pub fn new(addr: IpAddr, port: u16, enable_playground: bool) -> Self {
    TmsWeb {
      addr,
      port,
      enable_playground,
    }
  }

  pub async fn run(&self) -> Result<()> {
    log::info!("Web Server Starting on {}:{}", self.addr, self.port);

    if self.enable_playground {
      log::warn!("GraphQL Playground Enabled, this should only be used for debugging!");
    }

    let schema = Schema::build(
      RootQuery::default(),
      RootMutation::default(),
      RootSubscription::default(),
    )
    .finish();

    let mut app = Router::new()
      .route(GRAPHQL_ENDPOINT, post(graphql_handler))
      .route_service(GRAPHQL_SUBSCRIPTION_ENDPOINT, GraphQLSubscription::new(schema.clone()))
      .with_state(schema);

    if self.enable_playground {
      app = app.route(GRAPHQL_PLAYGROUND_ENDPOINT, get(playground_handler));
    }

    axum::serve(TcpListener::bind(format!("{}:{}", self.addr, self.port)).await?, app).await?;

    Ok(())
  }
}
