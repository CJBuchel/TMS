extern crate openssl;

use std::process::Command;

use futures::StreamExt;
use futures::FutureExt;
use openssl::asn1::Asn1Time;
use openssl::hash::MessageDigest;
use openssl::pkey::{PKey};
use openssl::rsa::Padding;
use openssl::rsa::Rsa;
use openssl::x509::{X509Builder};
use warp::Filter;

#[tokio::main]
async fn main() {
  pretty_env_logger::init();
  println!("Starting main server...");

  // Generate RSA Key
  let rsa = Rsa::generate(2048).unwrap();
  let raw_private_key = PKey::from_rsa(rsa.clone()).unwrap();
  let raw_public_key = rsa.public_key_to_pem().unwrap();
  let raw_public_key = PKey::public_key_from_pem(raw_public_key.as_slice()).unwrap();

  // Time
  let not_before = Asn1Time::days_from_now(0).unwrap();
  let not_after = Asn1Time::days_from_now(3650).unwrap();

  // Name builder
  let mut x509_name = openssl::x509::X509NameBuilder::new().unwrap();
  x509_name.append_entry_by_text("C", "AU").unwrap();
  x509_name.append_entry_by_text("ST", "CA").unwrap();
  x509_name.append_entry_by_text("O", "TMS").unwrap();
  x509_name.append_entry_by_text("CN", "TMS Host").unwrap();
  let x509_name = x509_name.build();

  // X509 Builder
  let mut x509_builder = X509Builder::new().unwrap();
  // x509_builder.set_version(2).unwrap();
  x509_builder.set_subject_name(&x509_name).unwrap();
  x509_builder.set_issuer_name(&x509_name).unwrap();
  x509_builder.set_pubkey(&raw_public_key).unwrap();
  x509_builder.set_not_before(&not_before).unwrap();
  x509_builder.set_not_after(&not_after).unwrap();
  x509_builder.sign(&raw_private_key, MessageDigest::sha256()).unwrap();
  let x509_cert = x509_builder.build();
  
  let private_key = rsa.private_key_to_pem().unwrap();
  let public_key = x509_cert.to_pem().unwrap();

  let routes = warp::path("echo")
  .and(warp::ws())
  .map(|ws: warp::ws::Ws| {
    ws.on_upgrade(|websocket| {
      // Just echo all messages back...
      let (tx, rx) = websocket.split();
      rx.forward(tx).map(|result| {
          if let Err(e) = result {
            eprintln!("websocket error: {:?}", e);
          }
        })
      })
    });
    
  println!("Private key\n {}", String::from_utf8(private_key.clone()).unwrap());
  println!("Public key\n {}", String::from_utf8(public_key.clone()).unwrap());

  let data = "A quick brown fox jumps over the lazy dog.";

  // Encrypt with public key
  let mut buf: Vec<u8> = vec![0; rsa.size() as usize];
  let _ = rsa.public_encrypt(data.as_bytes(), &mut buf, Padding::PKCS1).unwrap();
  println!("Encrypted: {:?}", buf);

  let data = buf;

  // Decrypt with private key
  let mut buf: Vec<u8> = vec![0; rsa.size() as usize];
  let _ = rsa.private_decrypt(&data, &mut buf, Padding::PKCS1).unwrap();
  println!("Decrypted: {}", String::from_utf8(buf).unwrap());

  // println!("Starting socket server");
  warp::serve(routes)
    // .tls()
    // .cert(public_key)
    // .key(private_key)
    // .cert_path("cert.pem")
    // .key_path("key.rsa")
    .run(([0,0,0,0], 2121))
    .await;
}
