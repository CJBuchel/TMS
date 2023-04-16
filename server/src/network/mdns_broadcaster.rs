use local_ip_address::linux::local_ip;
use log::info;
use mdns_sd::{ServiceDaemon, ServiceInfo};
use std::{collections::HashMap, fmt::format};

pub struct MDNSBroadcaster {
  port: u16,
  name: String
}

impl MDNSBroadcaster {
  pub fn new (port: u16, name: String) -> Self {
    Self { port, name }
  }

  pub async fn start(&self) {
    info!("mDNS Service Starting");
    let mdns = ServiceDaemon::new().expect("Failed to create mDNS daemon");

    let service_name: String = format!("{}._udp.local.", self.name);

    // Create service info
    let service_type = service_name.to_owned();
    let instance_name = format!("{}_instance", self.name);
    let host_ipv4 = format!("{}", local_ip().unwrap());
    let host_name = format!("{}.local.", local_ip().unwrap());
    let port = self.port;
    let properties = [("property_1", "test")];

    let service = ServiceInfo::new(
      service_type.as_str(),
      instance_name.as_str(),
      host_name.as_str(),
      host_ipv4.as_str(),
      port,
      &properties[..],
    ).unwrap();

    mdns.register(service).expect("Failed to register the mDNS service");
  }
}