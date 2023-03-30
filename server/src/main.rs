// mod network;

// #[tokio::main]
// async fn main() {
//   println!("Program starting");
//   network::network::start().await;
// }

extern crate openssl;

use openssl::rsa::{Rsa};
use openssl::symm::Cipher;
use openssl::*;
use warp::{Filter};

// https://blog.devgenius.io/building-a-secure-websocket-server-with-rust-warp-in-docker-20e842d143af

#[tokio::main]
async fn main() {
  let passphrase = "this_manages_stuff";

  let rsa = Rsa::generate(2048).unwrap();
  let private_key: Vec<u8> = rsa.private_key_to_pem().unwrap();
  let public_key: Vec<u8> = rsa.public_key_to_pem().unwrap();

  println!("Private key\n {}", String::from_utf8(private_key.clone()).unwrap());
  println!("Public key\n {}", String::from_utf8(public_key.clone()).unwrap());

  let current_dir = std::env::current_dir().expect("failed to read current directory").display().to_string();
  let routes = warp::get().and(warp::fs::dir(current_dir));

  warp::serve(routes)
    .tls()
    .cert(public_key)
    .key(private_key)
    // .cert_path("cert.pem")
    // .key_path("key.rsa")
    .run(([0,0,0,0], 9231))
    .await;
}
