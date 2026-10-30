//! Binding and serving. With TLS, HTTPS runs on its own port and the plain HTTP port redirects to it.

use std::future::Future;
use std::net::{IpAddr, SocketAddr};
use std::path::PathBuf;
use std::time::Duration;

use anyhow::Context;
use axum::Router;
use axum::extract::Request;
use axum::http::StatusCode;
use axum::http::header::{HOST, LOCATION};
use axum::response::{IntoResponse, Response};
use axum_server::Handle;

use crate::{AppState, router};

#[derive(Debug, Clone)]
pub struct TlsOptions {
  pub cert: PathBuf,
  pub key: PathBuf,
  pub port: u16,
}

#[derive(Debug, Clone)]
pub struct ServerOptions {
  pub bind: IpAddr,
  pub port: u16,
  pub tls: Option<TlsOptions>,
  /// The web client folder.
  pub web_dir: PathBuf,
}

const SHUTDOWN_GRACE: Duration = Duration::from_secs(5);

/// Serves until `shutdown` completes. `on_listening` runs once every socket is bound, which is when the
/// caller can print join URLs. Binding errors (such as a port already in use) are returned.
pub async fn run(
  state: AppState,
  options: ServerOptions,
  shutdown: impl Future<Output = ()> + Send + 'static,
  on_listening: impl FnOnce() + Send + 'static,
) -> anyhow::Result<()> {
  let app = router(state, &options.web_dir).into_make_service_with_connect_info::<SocketAddr>();
  let handle: Handle<SocketAddr> = Handle::new();
  // Only used with TLS: the plain-HTTP listener that redirects to HTTPS. Both stop on the same signal.
  let redirect_handle: Handle<SocketAddr> = Handle::new();
  let (main_watcher, redirect_watcher) = (handle.clone(), redirect_handle.clone());
  tokio::spawn(async move {
    shutdown.await;
    main_watcher.graceful_shutdown(Some(SHUTDOWN_GRACE));
    redirect_watcher.graceful_shutdown(Some(SHUTDOWN_GRACE));
  });

  let http_addr = SocketAddr::new(options.bind, options.port);
  match options.tls {
    None => {
      notify_when_listening(&handle, on_listening);
      axum_server::bind(http_addr)
        .handle(handle)
        .serve(app)
        .await
        .with_context(|| format!("serving HTTP on {http_addr}"))
    }
    Some(tls) => {
      let _ = rustls::crypto::ring::default_provider().install_default();
      let config = axum_server::tls_rustls::RustlsConfig::from_pem_file(&tls.cert, &tls.key)
        .await
        .with_context(|| {
          format!(
            "loading TLS certificate {} and key {}",
            tls.cert.display(),
            tls.key.display()
          )
        })?;
      let tls_addr = SocketAddr::new(options.bind, tls.port);
      notify_when_listening(&handle, on_listening);
      let https = axum_server::bind_rustls(tls_addr, config).handle(handle).serve(app);
      let redirect = axum_server::bind(http_addr)
        .handle(redirect_handle)
        .serve(redirect_router(tls.port).into_make_service());
      tokio::try_join!(
        async { https.await.with_context(|| format!("serving HTTPS on {tls_addr}")) },
        async {
          redirect
            .await
            .with_context(|| format!("serving the HTTPS redirect on {http_addr}"))
        },
      )?;
      Ok(())
    }
  }
}

fn notify_when_listening(handle: &Handle<SocketAddr>, on_listening: impl FnOnce() + Send + 'static) {
  let handle = handle.clone();
  tokio::spawn(async move {
    if handle.listening().await.is_some() {
      on_listening();
    }
  });
}

/// Sends every plain-HTTP request to the same host and path on the HTTPS port.
fn redirect_router(https_port: u16) -> Router {
  Router::new().fallback(move |request: Request| async move { redirect(&request, https_port) })
}

fn redirect(request: &Request, https_port: u16) -> Response {
  let Some(host) = request.headers().get(HOST).and_then(|h| h.to_str().ok()) else {
    return (StatusCode::BAD_REQUEST, "missing Host header").into_response();
  };
  let host = strip_port(host);
  let port = if https_port == 443 {
    String::new()
  } else {
    format!(":{https_port}")
  };
  let path = request.uri().path_and_query().map_or("/", |p| p.as_str());
  let location = format!("https://{host}{port}{path}");
  (StatusCode::PERMANENT_REDIRECT, [(LOCATION, location)]).into_response()
}

/// `example.org:8080` becomes `example.org`; `[::1]:8080` becomes `[::1]`.
fn strip_port(host: &str) -> &str {
  if host.starts_with('[') {
    host.split_inclusive(']').next().unwrap_or(host)
  } else {
    host.split(':').next().unwrap_or(host)
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn redirect_keeps_host_and_path() {
    let request = Request::builder()
      .uri("/settings?x=1")
      .header(HOST, "tms.local:8080")
      .body(axum::body::Body::empty())
      .unwrap();
    let response = redirect(&request, 8443);
    assert_eq!(response.status(), StatusCode::PERMANENT_REDIRECT);
    assert_eq!(response.headers()[LOCATION], "https://tms.local:8443/settings?x=1");

    let request = Request::builder()
      .uri("/")
      .header(HOST, "[::1]:80")
      .body(axum::body::Body::empty())
      .unwrap();
    assert_eq!(redirect(&request, 443).headers()[LOCATION], "https://[::1]/");
  }
}
