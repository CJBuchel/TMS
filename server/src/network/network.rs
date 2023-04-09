// extern crate openssl;
use openssl::{rsa::{Rsa, Padding}, asn1::Asn1Time, x509::X509Builder, hash::MessageDigest, pkey::Private};

pub struct Network {
  private_key: Vec<u8>,
  public_key: Vec<u8>,
  rsa: Rsa<Private>
}

impl Network {
  pub fn start() -> Self {
    // Generate the RSA Key
    let rsa = Rsa::generate(2048).unwrap();
    let raw_private_key = openssl::pkey::PKey::from_rsa(rsa.clone()).unwrap();
    let raw_public_key = rsa.public_key_to_pem().unwrap();
    let raw_public_key = openssl::pkey::PKey::public_key_from_pem(raw_public_key.as_slice()).unwrap();

    // Time
    let not_before = Asn1Time::days_from_now(0).unwrap();
    let not_after = Asn1Time::days_from_now(3690).unwrap();

    // Name builder
    let mut x509_name = openssl::x509::X509NameBuilder::new().unwrap();
    x509_name.append_entry_by_text("C", "AU").unwrap();
    x509_name.append_entry_by_text("ST", "CA").unwrap();
    x509_name.append_entry_by_text("O", "TMS").unwrap();
    x509_name.append_entry_by_text("CN", "TMS Host").unwrap();
    let x509_name = x509_name.build();

    // x509 Builder
    let mut x509_builder = X509Builder::new().unwrap();
    // x509_builder.set_version(2).unwrap();
    x509_builder.set_subject_name(&x509_name).unwrap();
    x509_builder.set_issuer_name(&x509_name).unwrap();
    x509_builder.set_pubkey(&raw_public_key).unwrap();
    x509_builder.set_not_before(&not_before).unwrap();
    x509_builder.set_not_after(&not_after).unwrap();
    x509_builder.sign(&raw_private_key, MessageDigest::sha256()).unwrap();
    let x509_cert = x509_builder.build();

    Self { 
      private_key: rsa.private_key_to_pem().unwrap(), 
      public_key: x509_cert.to_pem().unwrap(), 
      rsa: rsa
    }
    // Start warp server
  }

  pub fn encrypt(&self, data: String) -> Vec<u8> {
    let mut buf: Vec<u8> = vec![0; self.rsa.size() as usize];
    let _ = self.rsa.public_encrypt(data.as_bytes(), &mut buf, Padding::PKCS1).unwrap();
    return buf;
  }

  pub fn decrypt(&self, buf: Vec<u8>) -> String {
    let mut data: Vec<u8> = vec![0; self.rsa.size() as usize];
    let _ = self.rsa.private_decrypt(&buf, &mut data, Padding::PKCS1);
    return String::from_utf8(data).unwrap();
  }
}