//! The web client is a folder of files: `web/` beside the program in a release, or the `dx build` output during
//! development. When the folder has no `index.html`, pages explain how to get the client instead of a bare 404.

use std::path::Path;

use axum::http::StatusCode;
use axum::response::Html;

pub fn has_client(dir: &Path) -> bool {
  dir.join("index.html").is_file()
}

pub fn missing_client_page(dir: &Path) -> (StatusCode, Html<String>) {
  let dir = dir.display().to_string().replace('&', "&amp;").replace('<', "&lt;");
  (
    StatusCode::SERVICE_UNAVAILABLE,
    Html(format!(
      "<!doctype html><meta charset=utf-8><title>TMS</title>\
       <body style=\"font-family:system-ui,sans-serif;max-width:40rem;margin:3rem auto;padding:0 1rem\">\
       <h1>The TMS server is running, but the web client is missing</h1>\
       <p>No <code>index.html</code> was found in <code>{dir}</code>.</p>\
       <p>In a release, the <code>web</code> folder belongs next to the <code>tms</code> program. Unzip the whole \
       release folder, or start the server with <code>--web-dir</code> pointing at the client.</p>\
       <p>From the source code, build the client with <code>dx build --package tms-client</code> and restart the \
       server.</p></body>"
    )),
  )
}
