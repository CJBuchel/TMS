mod app;
mod components;
mod net;
mod pages;
mod routes;
mod shell;
mod store;
mod time;

fn main() {
  dioxus::launch(app::App);
}
