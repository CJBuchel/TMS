import 'package:flutter/material.dart';
import 'package:tms/network/network.dart';
import 'package:tms/responsive.dart';

class Landing extends StatefulWidget {
  Landing({super.key});

  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  String _serverIP = '';
  Widget _searchState = const Text("");
  TextEditingController _controller = new TextEditingController();

  void findServer() async {
    setState(() {
      _searchState = const Text("Searching For Server...", style: TextStyle(color: Colors.white));
    });

    var state = await Network.findServer();
    if (state == NetworkConnectionState.connected) {
      setState(() {
        _searchState = const Text("Found Server", style: TextStyle(color: Colors.green));
      });
    } else if (state == NetworkConnectionState.connectedNoPulse) {
      setState(() {
        _searchState = const Text("Connected With No Pulse", style: TextStyle(color: Colors.amber));
      });
    } else {
      setState(() {
        _searchState = const Text("Could Not Find Server", style: TextStyle(color: Colors.red));
      });
    }

    _serverIP = await Network.getServerIP();
    _controller.text = _serverIP;
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
            children: <Widget>[
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Server Address', hintText: 'Enter the address of the server, e.g: `10.53.33.2`'),
                  ),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [_searchState],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: buttonHeight,
                width: buttonWidth,
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
                child: ElevatedButton.icon(
                  onPressed: () {
                    Network.test();
                  },
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
