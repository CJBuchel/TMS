import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:tms/network/network.dart';
import 'package:tms/responsive.dart';
import 'package:tms/screens/shared/tool_bar.dart';

class Connection extends StatefulWidget {
  const Connection({super.key});

  @override
  ConnectionState createState() => ConnectionState();
}

class ConnectionState extends State<Connection> {
  final TextEditingController _controller = TextEditingController();
  Text _serverVersionText = const Text("Server-N/A", style: TextStyle(color: Colors.red));
  Text _clientVersionText = Text("Client-${dotenv.env['TMS_TAG']}", style: const TextStyle(color: Colors.green));
  bool _autoConfigureNetwork = true;

  int versionToNumber(String version) {
    var parts = version.split(".");
    if (parts.length != 3) {
      return 0;
    }
    var major = int.parse(parts[0]);
    var minor = int.parse(parts[1]);
    var patch = int.parse(parts[2]);
    return major * 10000 + minor * 100 + patch;
  }

  void checkVersion() async {
    Network.getServerVersion().then((value) {
      setState(() {
        if (versionToNumber(value) == versionToNumber("${dotenv.env['TMS_TAG']}")) {
          _serverVersionText = Text("Server-$value", style: const TextStyle(color: Colors.green));
          _clientVersionText = Text("Client-${dotenv.env['TMS_TAG']}", style: const TextStyle(color: Colors.green));
        } else if (versionToNumber(value) < versionToNumber("${dotenv.env['TMS_TAG']}")) {
          _serverVersionText = Text("Server-$value", style: const TextStyle(color: Colors.red));
          _clientVersionText = Text("Client-${dotenv.env['TMS_TAG']}", style: const TextStyle(color: Colors.green));
        } else if (versionToNumber(value) > versionToNumber("${dotenv.env['TMS_TAG']}")) {
          _serverVersionText = Text("Server-$value", style: const TextStyle(color: Colors.green));
          _clientVersionText = Text("Client-${dotenv.env['TMS_TAG']}", style: const TextStyle(color: Colors.red));
        }
      });
    });
  }

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

    checkVersion();
    Network.serverVersion.addListener(checkVersion);
  }

  @override
  void dispose() {
    super.dispose();
    Network.serverVersion.removeListener(checkVersion);
  }

  void findServer() async {
    var found = await Network.findServer();
    if (found) {
      Logger().i("found");
      Network.getServerIP().then((value) {
        setState(() {
          _controller.text = value;
        });
      });
    } else {
      Logger().w("Couldn't find server");
    }
  }

  void connectToServer() async {
    Network.reset().then((v) {
      Network.setServerIP(_controller.text).then((v) async {
        Logger().i(await Network.getServerIP());
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
      appBar: TmsToolBar(displayActions: false),
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

          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: buttonHeight,
                  width: buttonWidth,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Logger().i("Finding server");
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
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [const Text("Build: [ "), _clientVersionText, const Text(",  "), _serverVersionText, const Text(" ]")],
            ),
          ),
        ],
      ),
    );
  }
}
