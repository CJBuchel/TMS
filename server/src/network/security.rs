use log::info;
use openssl::{rsa::{Rsa, Padding}, pkey::Private};
use base64::{Engine, engine::general_purpose};

const BYTE_SIZE: usize = 8;
const SIZE: usize = 4096;
const PKCS1_PADDING_SIZE: usize = 11;

#[derive(Clone)]
pub struct Security {
  pub public_key: Vec<u8>,
  pub private_key: Vec<u8>,
  rsa: Rsa<Private>
}

impl Security {
  pub fn new() -> Self {
    info!("Encryption Size in bits: {}", SIZE);
    info!("Generating Encryption Keys");
    let raw_rsa = Rsa::generate(u32::try_from(SIZE).unwrap()).unwrap();
    let raw_private_key = raw_rsa.private_key_to_pem().unwrap();
    let raw_public_key = raw_rsa.public_key_to_pem().unwrap();

    info!("Public Key: \n{}\n", String::from_utf8(raw_public_key.clone()).unwrap());
    info!("Private Key: \n{}\n", String::from_utf8(raw_private_key.clone()).unwrap());

    Self {
      public_key: raw_public_key,
      private_key: raw_private_key,
      rsa: raw_rsa
    }
  }
}

// Encrypt using a public key, returns a string in base64 bytes
pub fn encrypt(key: String, data: String) -> String {
  let rsa = Rsa::public_key_from_pem_pkcs1(key.as_bytes()).unwrap();

  let channels = data.as_bytes().chunks((SIZE/BYTE_SIZE)-PKCS1_PADDING_SIZE);
  let mut encrypted_data: Vec<u8> = vec![];
  
  for channel_chunk in channels {
    let mut buf = vec![0; rsa.size() as usize];
    let _ = rsa.public_encrypt(channel_chunk, &mut buf, Padding::PKCS1).unwrap();
    encrypted_data.append(&mut buf);
  }
  return general_purpose::STANDARD.encode(encrypted_data);
}

// Decrypt using private key, returns string
pub fn decrypt(key: String, buf: String) -> String {
  let rsa = Rsa::private_key_from_pem(key.as_bytes()).unwrap();

  let decoded_buff = general_purpose::STANDARD.decode(buf).unwrap();
  let channels = decoded_buff.chunks(SIZE/8);
  let mut decrypted_data:String = "".to_string();
  for channel_chunk in channels {
    let mut data: Vec<u8> = vec![0; rsa.size() as usize];
    let _ = rsa.private_decrypt(channel_chunk, &mut data, Padding::PKCS1).unwrap();
    let string_data = String::from_utf8(data).unwrap().trim_matches(char::from(0)).to_string();
    decrypted_data.push_str(string_data.as_str());
  }
  return decrypted_data
}

// Encrypt using local public key from security object
pub fn encrypt_local(security: Security, data: String) -> String {
  let channels = data.as_bytes().chunks((SIZE/BYTE_SIZE)-PKCS1_PADDING_SIZE);
  let mut encrypted_data: Vec<u8> = vec![];
  
  for channel_chunk in channels {
    let mut buf = vec![0; security.rsa.size() as usize];
    let _ = security.rsa.public_encrypt(channel_chunk, &mut buf, Padding::PKCS1).unwrap();
    encrypted_data.append(&mut buf);
  }
  return general_purpose::STANDARD.encode(encrypted_data);
}

// Decrypt using local private key from security object
pub fn decrypt_local(security: Security, buf: String) -> String {
  let decoded_buff = general_purpose::STANDARD.decode(buf).unwrap();
  let channels = decoded_buff.chunks(SIZE/8);
  let mut decrypted_data:String = "".to_string();
  for channel_chunk in channels {
    let mut data: Vec<u8> = vec![0; security.rsa.size() as usize];
    let _ = security.rsa.private_decrypt(channel_chunk, &mut data, Padding::PKCS1).unwrap();
    let string_data = String::from_utf8(data).unwrap().trim_matches(char::from(0)).to_string();
    decrypted_data.push_str(string_data.as_str());
  }
  return decrypted_data
}