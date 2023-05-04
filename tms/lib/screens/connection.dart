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
  final TextEditingController _controller = TextEditingController();
  bool _autoConfigureNetwork = true;

  @override
  void initState() {
    super.initState();
    Network.getServerIP().then((value) {
      setState(() {
        _controller.text = value;
      });
    });

    Network.getAutoConfig().then((value) {
      setState(() {
        _autoConfigureNetwork = value;
      });
    });
  }

  void findServer() async {
    var found = await Network.findServer();
    if (found) {
      print("found");
      Network.getServerIP().then((value) {
        setState(() {
          _controller.text = value;
        });
      });
    } else {
      print("Couldn't find server");
    }
  }

  void connectToServer() async {
    Network.reset().then((v) {
      Network.setServerIP(_controller.text).then((v) async {
        print(await Network.getServerIP());
        await Network.connect();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var imageSize = <double>[300, 500];
    double textSize = 20;
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Auto configure
              SizedBox(
                width: buttonWidth,
                child: ListTile(
                  title: Text(
                    "Auto",
                    style: TextStyle(color: Colors.white, fontSize: textSize),
                  ),
                  leading: Radio<bool>(
                      value: true,
                      groupValue: _autoConfigureNetwork,
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() {
                            _autoConfigureNetwork = value;
                            Network.setAutoConfig(value);
                          });
                        }
                      }),
                ),
              ),

              // Manual configure
              SizedBox(
                width: buttonWidth,
                child: ListTile(
                  title: Text(
                    "Manual",
                    style: TextStyle(color: Colors.white, fontSize: textSize),
                  ),
                  leading: Radio<bool>(
                      value: false,
                      groupValue: _autoConfigureNetwork,
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() {
                            _autoConfigureNetwork = value;
                            Network.setAutoConfig(value);
                          });
                        }
                      }),
                ),
              )
            ],
          ),
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
            children: <Widget>[
              SizedBox(
                height: buttonHeight,
                width: buttonWidth,
                child: ElevatedButton.icon(
                  onPressed: () {
                    print("Finding server");
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
