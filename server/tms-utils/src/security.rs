use log::info;
use openssl::{rsa::{Rsa, Padding}};
use base64::{Engine, engine::general_purpose};

const PKCS1_PADDING_SIZE: usize = 11; // 11

// Encrypt using a public key, returns a string in base64 bytes
pub fn encrypt(key: String, data: String) -> String {
  if data.is_empty() || key.is_empty() {
    return data;
  }

  let rsa = Rsa::public_key_from_pem_pkcs1(key.as_bytes()).unwrap();

  let channels = data.as_bytes().chunks(rsa.size() as usize - PKCS1_PADDING_SIZE);
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
  if buf.is_empty() || key.is_empty() {
    return buf;
  }

  let rsa = Rsa::private_key_from_pem(key.as_bytes()).unwrap();

  let decoded_buff = general_purpose::STANDARD.decode(buf).unwrap();
  let channels = decoded_buff.chunks(rsa.size() as usize);
  let mut decrypted_data:String = "".to_string();

  for channel_chunk in channels {
    let mut data: Vec<u8> = vec![0; rsa.size() as usize];
    let _ = rsa.private_decrypt(channel_chunk, &mut data, Padding::PKCS1).unwrap();
    let string_data = String::from_utf8(data).unwrap().trim_matches(char::from(0)).to_string();
    decrypted_data.push_str(string_data.as_str());
  }

  return decrypted_data
}

#[derive(Clone)]
pub struct Security {
  pub public_key: Vec<u8>,
  pub private_key: Vec<u8>,
}

impl Security {
  pub fn new(bits: usize) -> Self {
    info!("Encryption Size in bits: {}", bits);
    info!("Generating Encryption Keys");
    let raw_rsa = Rsa::generate(u32::try_from(bits).unwrap()).unwrap();
    let raw_private_key = raw_rsa.private_key_to_pem().unwrap();
    let raw_public_key = raw_rsa.public_key_to_pem().unwrap();

    info!("Public Key: \n{}\n", String::from_utf8(raw_public_key.clone()).unwrap());
    info!("Private Key: \n{}\n", String::from_utf8(raw_private_key.clone()).unwrap());

    Self {
      public_key: raw_public_key,
      private_key: raw_private_key,
    }
  }

  pub fn encrypt(&self, data: String) -> String {
    return encrypt(String::from_utf8(self.public_key.to_owned()).unwrap(), data);
  }

  pub fn decrypt(&self, buf: String) -> String {
    return decrypt(String::from_utf8(self.private_key.to_owned()).unwrap(), buf);
  }
}
