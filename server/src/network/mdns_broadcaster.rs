use std::time::Duration;

use local_ip_address::local_ip;
use log::{info, warn};
use mdns_sd::{ServiceDaemon, ServiceInfo};
use tokio::time::sleep;
use tokio::signal;


pub struct MDNSBroadcaster {
  port: u16,
  name: String,
}

impl MDNSBroadcaster {
  pub fn new (port: u16, name: String) -> Self {
    Self { port, name }
  }

  fn get_service_from_ip(&self, ip: &str) -> ServiceInfo {
    let service_name: String = format!("{}._udp.local.", self.name);

    // Create service info
    let service_type = service_name.to_owned();
    let instance_name = format!("{}_instance", self.name);
    let host_ipv4 = format!("{}", ip);
    let host_name = format!("{}.local.", ip);
    let port = self.port;
    let properties = [("property_1", "test")];

    warn!("Staring mDNS Service: {}, with ip: {}", service_name, ip);

    ServiceInfo::new(
      service_type.as_str(),
      instance_name.as_str(),
      host_name.as_str(),
      host_ipv4.as_str(),
      port,
      &properties[..],
    ).unwrap()
  }

  pub async fn start(&self) {
    info!("Starting mDNS service");
    let mdns = ServiceDaemon::new().expect("Failed to create mDNS daemon");
    let mut known_ip: String = format!("{}", local_ip().expect("Failed to get local ip address"));
    mdns.register(self.get_service_from_ip(&known_ip)).expect("Failed to register the mDNS service");

    // periodically check the ip to see if it's changed (dhcp ruling)
    loop {
      tokio::select! {
        _ = sleep(Duration::from_secs(10)) => {
          let current_ip: String = format!("{}", local_ip().expect("Failed to get local ip address"));
          if current_ip != known_ip {
            warn!("IP address changed to: {}, ", current_ip);
    
            // unregister old service
            let mut service = self.get_service_from_ip(&known_ip);
            mdns.unregister(&service.get_fullname()).expect("Failed to unregister the mDNS service");
            // switch the ip
            known_ip = current_ip;
            // register new service
            service = self.get_service_from_ip(&known_ip);
            mdns.register(service).expect("Failed to register the mDNS service");
          }
        },

        // ctrl-c
        _ = signal::ctrl_c() => {
          warn!("Stopping mDNS service");
          break;
        },
      }
    }
  }
}