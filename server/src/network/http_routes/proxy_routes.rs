use log::{warn, error};
use rocket::{get, http::Status};
use tms_utils::{TmsRouteResponse, TmsRespond, network_schemas::ProxyImageResponse};

#[get("/proxy_image/get?<url>")]
pub async fn proxy_image_get_route(url: String) -> TmsRouteResponse<()> {
  match reqwest::get(url.clone()).await {
    Ok(res) => {
      match res.bytes().await {
        Ok(image) => {
          let response = ProxyImageResponse {
            image: image.to_vec()
          };
          let m: String = serde_json::to_string(&response).unwrap();
          TmsRespond!(Status::Ok, m);
        },
        Err(e) => {
          TmsRespond!(Status::InternalServerError, e.to_string())
        }
      }
    },
    Err(e) => {
      TmsRespond!(Status::InternalServerError, e.to_string())
    }
  }
}