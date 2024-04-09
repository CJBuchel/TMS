import 'package:multicast_dns/multicast_dns.dart';
import 'package:tms/local_storage.dart';
import 'package:tms/logger.dart';

class MdnsController {
  Future<(bool, String)> findServer() async {
    TmsLogger().i("Finding TMS server...");
    const String name = mdnsName;
    final MDnsClient client = MDnsClient();
    await client.start();

    await for (PtrResourceRecord ptr in client.lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(name))) {
      var srvRecords = client.lookup<SrvResourceRecord>(ResourceRecordQuery.service(ptr.domainName));
      await for (SrvResourceRecord srv in srvRecords) {
        var ipRecords = client.lookup<IPAddressResourceRecord>(ResourceRecordQuery.addressIPv4(srv.target));
        await for (final IPAddressResourceRecord ip in ipRecords) {
          TmsLogger().i("Found TMS server at ${ip.address}:${srv.port}");
          client.stop();
          return (true, "${ip.address}");
        }
      }
    }

    TmsLogger().w("[MDNS] Failed to find TMS server");
    return (false, "");
  }
}
