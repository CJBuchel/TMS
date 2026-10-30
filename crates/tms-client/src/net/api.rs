//! Typed REST client for `/api/v1`. Same origin as the page, so no CORS and no configuration.

use gloo_net::http::{Request, RequestBuilder};
use serde::Serialize;
use serde::de::DeserializeOwned;
use tms_core::dto::ApiErrorBody;

const BASE: &str = "/api/v1";

#[derive(Debug, Clone, PartialEq)]
pub enum ApiFailure {
  /// The server could not be reached at all.
  Network(String),
  /// The server answered with an error body.
  Api {
    status: u16,
    code: String,
    message: String,
    details: Vec<String>,
  },
}

impl ApiFailure {
  pub fn message(&self) -> String {
    match self {
      ApiFailure::Network(_) => "Cannot reach the server.".to_owned(),
      ApiFailure::Api { message, .. } => message.clone(),
    }
  }

  /// Individual problems behind the message, such as each bad line of an imported file.
  pub fn details(&self) -> Vec<String> {
    match self {
      ApiFailure::Network(_) => Vec::new(),
      ApiFailure::Api { details, .. } => details.clone(),
    }
  }
}

fn with_auth(builder: RequestBuilder, token: Option<&str>) -> RequestBuilder {
  match token {
    Some(t) => builder.header("Authorization", &format!("Bearer {t}")),
    None => builder,
  }
}

fn url(path: &str) -> String {
  format!("{BASE}{path}")
}

// Used as a `map_err` adapter, which hands over the error by value.
#[allow(clippy::needless_pass_by_value)]
fn network<E: ToString>(e: E) -> ApiFailure {
  ApiFailure::Network(e.to_string())
}

async fn send(request: Request) -> Result<gloo_net::http::Response, ApiFailure> {
  let response = request.send().await.map_err(network)?;
  if response.ok() {
    return Ok(response);
  }
  let status = response.status();
  Err(match response.json::<ApiErrorBody>().await {
    Ok(body) => ApiFailure::Api {
      status,
      code: body.code,
      message: body.message,
      details: body.details,
    },
    Err(_) => ApiFailure::Api {
      status,
      code: "http".into(),
      message: format!("Server error ({status})."),
      details: Vec::new(),
    },
  })
}

async fn decode<T: DeserializeOwned>(response: gloo_net::http::Response) -> Result<T, ApiFailure> {
  let status = response.status();
  response.json().await.map_err(|e| ApiFailure::Api {
    status,
    code: "decode".into(),
    message: e.to_string(),
    details: Vec::new(),
  })
}

pub async fn get<T: DeserializeOwned>(path: &str, token: Option<&str>) -> Result<T, ApiFailure> {
  let request = with_auth(Request::get(&url(path)), token).build().map_err(network)?;
  decode(send(request).await?).await
}

pub async fn post<B: Serialize, T: DeserializeOwned>(
  path: &str,
  token: Option<&str>,
  body: &B,
) -> Result<T, ApiFailure> {
  let request = with_auth(Request::post(&url(path)), token)
    .json(body)
    .map_err(network)?;
  decode(send(request).await?).await
}

/// For endpoints that answer 204 No Content.
pub async fn post_empty<B: Serialize>(path: &str, token: Option<&str>, body: &B) -> Result<(), ApiFailure> {
  let request = with_auth(Request::post(&url(path)), token)
    .json(body)
    .map_err(network)?;
  send(request).await.map(|_| ())
}

/// Sends a text body, such as a CSV file.
pub async fn post_text<T: DeserializeOwned>(path: &str, token: Option<&str>, text: String) -> Result<T, ApiFailure> {
  let request = with_auth(Request::post(&url(path)), token)
    .header("Content-Type", "text/csv; charset=utf-8")
    .body(text)
    .map_err(network)?;
  decode(send(request).await?).await
}

pub async fn patch<B: Serialize, T: DeserializeOwned>(
  path: &str,
  token: Option<&str>,
  body: &B,
) -> Result<T, ApiFailure> {
  let request = with_auth(Request::patch(&url(path)), token)
    .json(body)
    .map_err(network)?;
  decode(send(request).await?).await
}

pub async fn delete(path: &str, token: Option<&str>) -> Result<(), ApiFailure> {
  let request = with_auth(Request::delete(&url(path)), token).build().map_err(network)?;
  send(request).await.map(|_| ())
}

/// Fetches a file (a CSV export, a printable PDF) with the login token and hands it to the browser as a download.
pub async fn download(path: &str, token: Option<&str>, filename: &str) -> Result<(), ApiFailure> {
  use web_sys::wasm_bindgen::JsCast;
  let request = with_auth(Request::get(&url(path)), token).build().map_err(network)?;
  let response = send(request).await?;
  let content_type = response.headers().get("content-type").unwrap_or_default();
  let bytes = response.binary().await.map_err(network)?;
  let browser = |e: web_sys::wasm_bindgen::JsValue| ApiFailure::Network(format!("{e:?}"));
  let options = web_sys::BlobPropertyBag::new();
  options.set_type(&content_type);
  let parts = js_sys::Array::of1(&js_sys::Uint8Array::from(bytes.as_slice()));
  let blob = web_sys::Blob::new_with_u8_array_sequence_and_options(&parts, &options).map_err(browser)?;
  let href = web_sys::Url::create_object_url_with_blob(&blob).map_err(browser)?;
  let document = web_sys::window()
    .and_then(|w| w.document())
    .ok_or_else(|| ApiFailure::Network("no document".into()))?;
  let link: web_sys::HtmlElement = document.create_element("a").map_err(browser)?.unchecked_into();
  link.set_attribute("href", &href).map_err(browser)?;
  link.set_attribute("download", filename).map_err(browser)?;
  link.click();
  Ok(())
}
