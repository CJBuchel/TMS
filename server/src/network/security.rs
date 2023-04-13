use openssl::{rsa::{Rsa, Padding}, pkey::Private};
use base64::{Engine, engine::general_purpose};

#[derive(Clone)]
pub struct Security {
  pub public_key: Vec<u8>,
  rsa: Rsa<Private>
}

impl Security {
  pub fn new() -> Self {
    let raw_rsa = Rsa::generate(2048).unwrap();
    let raw_public_key = raw_rsa.public_key_to_pem_pkcs1().unwrap();

    Self {
      public_key: raw_public_key,
      rsa: raw_rsa
    }
  }
}

pub async fn encrypt(security: Security, data: String) -> Vec<u8> {
  let mut buf: Vec<u8> = vec![0; security.rsa.size() as usize];
  let _ = security.rsa.public_encrypt(data.as_bytes(), &mut buf, Padding::PKCS1).unwrap();
  println!("Buffer: {:?}", buf);
  return buf;
}

pub async fn decrypt(security: Security, buf: String) -> String {
  println!("Buffer: {:?}", buf);
  let decoded_buff = general_purpose::STANDARD.decode(buf).unwrap();
  let mut data: Vec<u8> = vec![0; security.rsa.size() as usize];
  let _ = security.rsa.private_decrypt(&decoded_buff, &mut data, Padding::PKCS1).unwrap();
  println!("Data: {:?}", data);
  return String::from_utf8(data).unwrap();
}