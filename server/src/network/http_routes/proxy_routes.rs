use reqwest::StatusCode;
use rocket::{get, http::Status};
use tms_utils::{TmsRouteResponse, TmsRespond, network_schemas::ProxyImageResponse};

// image cache
use lru_cache::LruCache;
use once_cell::sync::Lazy;

static IMAGE_CACHE: Lazy<tokio::sync::Mutex<LruCache<String, Vec<u8>>>> = Lazy::new(|| tokio::sync::Mutex::new(LruCache::new(100)));

#[get("/proxy_image/get?<url>")]
pub async fn proxy_image_get_route(url: String) -> TmsRouteResponse<()> {

  // check if we have the image cached first
  let mut cache = IMAGE_CACHE.lock().await;
  if let Some(image) = cache.get_mut(&url) {
    let response = ProxyImageResponse {
      image: image.clone()
    };
    let m: String = serde_json::to_string(&response).unwrap();
    TmsRespond!(Status::Ok, m);
  }

  // if not, get it from the url
  match reqwest::get(url.clone()).await {
    Ok(res) => {
      if res.status() == StatusCode::OK {
        match res.bytes().await {
          Ok(image) => {
            let response = ProxyImageResponse {
              image: image.to_vec()
            };
            cache.insert(url.clone(), image.to_vec());
            let m: String = serde_json::to_string(&response).unwrap();
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