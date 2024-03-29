use log::warn;
use reqwest::StatusCode;
use rocket::{get, http::Status};
use tms_utils::{TmsRouteResponse, TmsRespond, network_schemas::ProxyBytesResponse};

// image cache
use lru_cache::LruCache;
use once_cell::sync::Lazy;

static BYTES_CACHE: Lazy<tokio::sync::Mutex<LruCache<String, Vec<u8>>>> = Lazy::new(|| tokio::sync::Mutex::new(LruCache::new(100)));

#[get("/proxy_bytes/get?<url>")]
pub async fn proxy_image_get_route(url: String) -> TmsRouteResponse<()> {

  // check if we have the image cached first
  let cached_bytes = {
    let mut cache = BYTES_CACHE.lock().await;
    cache.get_mut(&url).cloned()
  };

  if let Some(bytes) = cached_bytes {
    let response = ProxyBytesResponse {
      bytes
    };
    let m: String = serde_json::to_string(&response).unwrap();
    TmsRespond!(Status::Ok, m);
  }

  // if not, get it from the url
  match reqwest::get(url.clone()).await {
    Ok(res) => {
      if res.status() == StatusCode::OK {
        match res.bytes().await {
          Ok(bytes) => {
            let response = ProxyBytesResponse {
              bytes: bytes.to_vec()
            };
            {
              let mut cache = BYTES_CACHE.lock().await;
              cache.insert(url.clone(), bytes.to_vec());
            }
            let m: String = serde_json::to_string(&response).unwrap();
            warn!("New proxy url, {} caching bytes...", url);
            TmsRespond!(Status::Ok, m);
          },
          Err(e) => {
            TmsRespond!(Status::InternalServerError, e.to_string())
          }
        }
      } else {
        TmsRespond!(Status::InternalServerError, format!("Error: {}", res.status()))
      }
    },
    Err(e) => {
      TmsRespond!(Status::InternalServerError, e.to_string())
    }
  }

}