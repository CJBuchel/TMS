import 'package:flutter/material.dart';
import 'package:tms/network/http.dart';
import 'package:tms/network/network.dart';
import 'package:tms/network/ws.dart';
import 'package:tms/responsive.dart';
import 'package:tms/screens/shared/tool_bar.dart';

class Connection extends StatefulWidget {
  Connection({super.key});

  @override
  _ConnectionState createState() => _ConnectionState();
}

class _ConnectionState extends State<Connection> {
  String _serverIP = '';
  Widget _searchState = const Text("");
  Widget _connectState = const Text("");
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Network.getServerIP().then((value) {
      setState(() {
        _serverIP = value;
        _controller.text = value;
      });
    });
  }

  void findServer() async {
    setState(() {
      _searchState = const Text("Searching For Server...", style: TextStyle(color: Colors.white));
    });

    Network.findServer().then((found) {
      if (found) {
        _searchState = const Text("Found Server", style: TextStyle(color: Colors.green));
      } else {
        Network.getStates().then((state) {
          switch (state.item1) {
            case NetworkHttpConnectionState.connected:
              _searchState = const Text("Found Server", style: TextStyle(color: Colors.green));
              break;
            case NetworkHttpConnectionState.connectedNoPulse:
              _searchState = const Text("Connected With No Pulse", style: TextStyle(color: Colors.amber));
              break;
            default:
              _searchState = const Text("Could Not Find Server", style: TextStyle(color: Colors.red));
          }
        });
      }
    });

    _serverIP = await Network.getServerIP();
    _controller.text = _serverIP;
  }

  void connectToServer() async {
    _connectState = const Text(" - Generating Encryption Keys", style: TextStyle(color: Colors.amber));

    Network.connect().then((v) {
      Network.getStates().then((state) {
        switch (state.item2) {
          case NetworkWebSocketState.connected:
            _connectState = const Text("- Connected", style: TextStyle(color: Colors.green));
            Navigator.pop(context, _connectState);
            break;
          default:
            _connectState = const Text(" - Websocket Failed To Connect", style: TextStyle(color: Colors.red));
        }
      });
    });
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
      appBar: TmsToolBar(),
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [_searchState, _connectState],
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
                    connectToServer();
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
