// tokio main
#[tokio::main]
async fn main() {
  let args = server::TmsConfig::parse_from_cli();
}
