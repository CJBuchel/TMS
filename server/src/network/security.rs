use openssl::{rsa::{Rsa, Padding}, pkey::Private};
use base64::{Engine, engine::general_purpose};

const SIZE: usize = 512;

#[derive(Clone)]
pub struct Security {
  pub public_key: Vec<u8>,
  rsa: Rsa<Private>
}

impl Security {
  pub fn new() -> Self {
    println!("Size in bytes: {}, {}", SIZE, u32::try_from(SIZE).unwrap());
    let raw_rsa = Rsa::generate(u32::try_from(SIZE).unwrap()).unwrap();
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
  let decoded_buff = general_purpose::STANDARD.decode(buf).unwrap();
  let decoded_channels = decoded_buff.chunks(SIZE/8);
  let mut decrypted_data:String = "".to_string();
  println!("Number of chunks: {:?}", decoded_channels.len());
  for channel_chunk in decoded_channels {
    let mut data: Vec<u8> = vec![0; security.rsa.size() as usize];
    let _ = security.rsa.private_decrypt(channel_chunk, &mut data, Padding::PKCS1).unwrap();
    decrypted_data.push_str(String::from_utf8(data).unwrap().as_str());
    // println!("Test get data: {}", String::from_utf8(data.clone()).unwrap());
  }
  // println!("Buffer: {:?}", decoded_buff);
  // println!("Data: {:?}", decrypted_data);
  return decrypted_data
}