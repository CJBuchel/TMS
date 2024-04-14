// import 'package:multicast_dns/multicast_dns.dart';
import 'package:nsd/nsd.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/utils/logger.dart';

class ServiceDiscoveryResponse {
  final bool tls;
  final String ip;
  final int port;

  ServiceDiscoveryResponse(this.tls, this.ip, this.port);
}

class ServiceDiscoveryController {
  // singleton
  static final ServiceDiscoveryController _instance = ServiceDiscoveryController._internal();

  factory ServiceDiscoveryController() {
    return _instance;
  }

  ServiceDiscoveryController._internal();
  bool _isRunning = false;
  Discovery? _discovery;

  Future<void> start() async {
    if (_isRunning) return;

    TmsLogger().i("Finding TMS server...");
    const String serviceType = "_tms-service._udp";

    _discovery = await startDiscovery(serviceType, ipLookupType: IpLookupType.any);
    if (_discovery != null) {
      _discovery!.addListener(() {
        for (final service in _discovery!.services) {
          if (service.name == "tms_server") {
            // get variables
            String ip = service.addresses?.first.address ?? "";
            int port = service.port ?? defaultServerPort;
            String protocol = service.txt?["tls"] == "true" ? "https" : "http";

            TmsLogger().i("Found TMS server at $ip:$port using $protocol");

            // set them in local storage
            TmsLocalStorageProvider().serverIp = ip;
            TmsLocalStorageProvider().serverPort = port;
            TmsLocalStorageProvider().serverHttpProtocol = protocol;
          }
        }
      });
      _isRunning = true;
    }
  }

  Future<void> stop() async {
    if (!_isRunning) {
      return;
    }

    if (_discovery != null) {
      TmsLogger().i("Stopping service discovery...");
      await stopDiscovery(_discovery!);
      _isRunning = false;
    }
  }
}
