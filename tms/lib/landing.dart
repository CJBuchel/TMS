import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:tms/responsive.dart';

class Landing extends StatefulWidget {
  Landing({super.key});

  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  String serverIP = '';
  Widget searchState = const Text("");
  void findServer() async {
    bool serverFound = false;
    if (!kIsWeb) {
      setState(() {
        searchState = const Text("Searching For Server...", style: TextStyle(color: Colors.white));
      });
      // final channel = WebSocketChannel.connect()
      const String name = '_mdns-tms-server._udp.local';
      final MDnsClient client = MDnsClient();
      await client.start();

      await for (final PtrResourceRecord ptr in client.lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(name))) {
        await for (final SrvResourceRecord srv in client.lookup<SrvResourceRecord>(ResourceRecordQuery.service(ptr.domainName))) {
          final String bundleId = ptr.domainName;
          await for (final IPAddressResourceRecord ip in client.lookup<IPAddressResourceRecord>(ResourceRecordQuery.addressIPv4(srv.target))) {
            serverFound = true;
            setState(() {
              serverIP = ip.address.address;
              searchState = const Text("Found Server", style: TextStyle(color: Colors.green));
            });
            print('Dart observatory found instance found at ${ip.address.address}:${srv.port} for "$bundleId"');
          }
        }
      }
      if (!serverFound) {
        setState(() {
          searchState = const Text("Could Not Find Server", style: TextStyle(color: Colors.red));
        });
      }
      print("Done");
      client.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    var imageSize = <double>[300, 500];
    double textSize = 25;
    double buttonWidth = 250;
    double buttonHeight = 50;
    if (Responsive.isTablet(context)) {
      imageSize = [150, 300];
      textSize = 15;
      buttonWidth = 200;
    } else if (Responsive.isMobile(context)) {
      imageSize = [100, 250];
      textSize = 11;
      buttonWidth = 150;
      buttonHeight = 40;
    }
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // y axis
        children: <Widget>[
          // Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // x axis
            crossAxisAlignment: CrossAxisAlignment.center, // y axis
            children: <Widget>[
              Image.asset(
                'assets/logos/TMS_LOGO.png',
                height: imageSize[0],
                width: imageSize[1],
              )
            ],
          ),
          // Address input
          Row(
            children: const <Widget>[
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 25),
                  child: TextField(
                    decoration:
                        InputDecoration(border: OutlineInputBorder(), labelText: 'Server Address', hintText: 'Enter the address of the server'),
                  ),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [searchState],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: buttonHeight,
                width: buttonWidth,
                // padding: const EdgeInsets.only(top: 10),
                // decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                child: ElevatedButton.icon(
                  onPressed: () {
                    findServer();
                  },
                  icon: const Icon(Icons.search),
                  label: Text(
                    'Scan for Server',
                    style: TextStyle(color: Colors.white, fontSize: textSize),
                  ),
                ),
              ),
              SizedBox(
                height: buttonHeight,
                width: buttonWidth,
                // padding: const EdgeInsets.only(top: 10),
                // decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(20)),
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.link),
                  label: Text(
                    'Connect',
                    style: TextStyle(color: Colors.white, fontSize: textSize),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
