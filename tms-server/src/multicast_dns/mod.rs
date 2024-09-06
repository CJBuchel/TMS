use mdns_sd::{ServiceDaemon, ServiceInfo};

pub struct MulticastDnsBroadcaster {
  service_info: Option<ServiceInfo>,
  m_dns: Option<ServiceDaemon>,
}

impl MulticastDnsBroadcaster {
  pub fn new(local_ip: String, advertise_port: u16, tls: bool) -> Self {
    let service_type = "_tms-service._udp.local.";
    let instance_name = "tms_server";
    let host_name = format!("{}.local.", local_ip);
    let properties = [("tls", tls)];

    let service = ServiceInfo::new(service_type, instance_name, &host_name, &local_ip, advertise_port, &properties[..]).ok();

    Self { service_info: service, m_dns: None }
  }

  pub fn start(&mut self) {
    log::info!("Starting Multicast DNS Service");

    self.m_dns = ServiceDaemon::new().ok();

    match &self.m_dns {
      Some(m_dns) => match &self.service_info {
        Some(service_info) => {
          m_dns.register(service_info.clone()).ok();
        }
        None => {
          log::error!("Service info not found");
        }
      },
      None => {
        log::error!("Service daemon not found");
      }
    }
  }

  pub fn stop(&self) {
    log::info!("Stopping Multicast DNS Service");

    match &self.m_dns {
      Some(m_dns) => match m_dns.shutdown() {
        Ok(_) => {
          log::info!("Service daemon stopped");
        }
        Err(e) => {
          log::error!("Service daemon failed to stop: {:?}", e);
        }
      },
      None => {
        log::error!("Service daemon not found");
      }
    }
  }
}
