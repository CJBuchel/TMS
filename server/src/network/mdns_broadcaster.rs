use local_ip_address::linux::local_ip;
use mdns_sd::{ServiceDaemon, ServiceInfo};
use std::{collections::HashMap, fmt::format};


pub fn start_broadcast(name: String) {
  println!("Starting mDNS server");
  let mdns = ServiceDaemon::new().expect("Failed to create mDNS daemon");

  // Create service info
  let service_type = format!("{}._udp.local.", name);
  let instance_name = format!("{}_instance", name);
  let host_ipv4 = format!("{}", local_ip().unwrap());
  let host_name = format!("{}.local.", local_ip().unwrap());
  let port = 2122;
  let properties = [("property_1", "test")];

  let service = ServiceInfo::new(
    service_type.as_str(),
    instance_name.as_str(),
    host_name.as_str(),
    host_ipv4.as_str(),
    port,
    &properties[..],
  ).unwrap();

  println!("Registering mDNS service");
  mdns.register(service).expect("Failed to register the mDNS service");
}