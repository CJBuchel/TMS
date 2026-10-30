//! The addresses people type or scan to reach the server.

use std::net::IpAddr;

use qrcode::QrCode;
use qrcode::render::unicode::Dense1x2;

use crate::settings::Settings;

/// Join URLs, best first: the public host if set, then every LAN IPv4 address (or the bound address).
pub fn urls(settings: &Settings) -> Vec<String> {
  let (scheme, port, default_port) = match &settings.tls {
    Some(tls) => ("https", tls.port, 443),
    None => ("http", settings.port, 80),
  };
  let port_suffix = if port == default_port {
    String::new()
  } else {
    format!(":{port}")
  };

  let mut hosts: Vec<String> = settings.public_host.iter().cloned().collect();
  if settings.bind.is_unspecified() {
    hosts.extend(lan_ipv4().into_iter().map(|ip| ip.to_string()));
  } else {
    hosts.push(format_ip(settings.bind));
  }
  if hosts.is_empty() {
    hosts.push("localhost".to_owned());
  }
  hosts.dedup();
  hosts
    .into_iter()
    .map(|host| format!("{scheme}://{host}{port_suffix}"))
    .collect()
}

fn lan_ipv4() -> Vec<IpAddr> {
  let Ok(interfaces) = local_ip_address::list_afinet_netifas() else {
    return Vec::new();
  };
  let mut ips: Vec<IpAddr> = interfaces
    .into_iter()
    .map(|(_, ip)| ip)
    .filter(|ip| ip.is_ipv4() && !ip.is_loopback())
    .collect();
  ips.sort();
  ips.dedup();
  ips
}

fn format_ip(ip: IpAddr) -> String {
  match ip {
    IpAddr::V4(v4) => v4.to_string(),
    IpAddr::V6(v6) => format!("[{v6}]"),
  }
}

/// A QR code drawn with Unicode half blocks, readable by phone cameras from a terminal.
pub fn terminal_qr(url: &str) -> Option<String> {
  let code = QrCode::new(url.as_bytes()).ok()?;
  Some(
    code
      .render::<Dense1x2>()
      .dark_color(Dense1x2::Light)
      .light_color(Dense1x2::Dark)
      .quiet_zone(true)
      .build(),
  )
}

#[cfg(test)]
mod tests {
  use std::net::Ipv4Addr;

  use super::*;
  use crate::settings::Tls;

  fn settings(bind: IpAddr, public_host: Option<&str>, tls: bool) -> Settings {
    Settings {
      data_dir: "x".into(),
      bind,
      port: 8080,
      tls: tls.then(|| Tls {
        cert: "c".into(),
        key: "k".into(),
        port: 443,
      }),
      public_host: public_host.map(Into::into),
      database_url: None,
      db_port: None,
      admin_password: None,
      log_level: "info".into(),
      web_dir: "web".into(),
      backup_interval_minutes: 10,
      backup_retain: 20,
      show_qr: true,
    }
  }

  #[test]
  fn specific_bind_and_public_host() {
    let s = settings(IpAddr::V4(Ipv4Addr::new(10, 0, 0, 5)), Some("tms.local"), false);
    assert_eq!(urls(&s), vec!["http://tms.local:8080", "http://10.0.0.5:8080"]);
  }

  #[test]
  fn https_on_443_has_no_port() {
    let s = settings(IpAddr::V4(Ipv4Addr::new(10, 0, 0, 5)), None, true);
    assert_eq!(urls(&s), vec!["https://10.0.0.5"]);
  }

  #[test]
  fn qr_renders() {
    let qr = terminal_qr("http://192.168.1.20:8080").unwrap();
    assert!(qr.lines().count() > 10);
  }
}
