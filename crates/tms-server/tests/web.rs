//! The web client folder. Test servers point at a folder that does not exist.

mod common;

use common::TestApp;
use reqwest::StatusCode;

#[tokio::test]
async fn a_missing_web_client_is_explained_and_the_api_still_works() {
  let app = TestApp::spawn().await;
  for path in ["/", "/match-control"] {
    let res = app.http.get(format!("http://{}{path}", app.addr)).send().await.unwrap();
    assert_eq!(res.status(), StatusCode::SERVICE_UNAVAILABLE);
    let page = res.text().await.unwrap();
    assert!(page.contains("the web client is missing"), "{page}");
    assert!(page.contains("/nonexistent"), "names the folder it looked in");
  }
  assert_eq!(app.get(None, "/version").await.status(), StatusCode::OK);
}
