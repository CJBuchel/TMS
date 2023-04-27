import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'dart:ui' as ui;

import 'package:tms/network/network.dart';
import 'package:tms/network/ws.dart';

class TmsToolBar extends StatefulWidget with PreferredSizeWidget {
  TmsToolBar({super.key});

  @override
  _TmsToolBarState createState() => _TmsToolBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TmsToolBarState extends State<TmsToolBar> {
  Icon connectionIcon = const Icon(Icons.signal_wifi_connected_no_internet_4_outlined, color: Colors.red);

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  void checkConnection() async {
    var ntState = await Network.getState();
    var wsState = await NetworkWebSocket.getState();
    if (ntState == NetworkConnectionState.connected && wsState == NetworkWebSocketState.connected) {
      setState(() {
        connectionIcon = const Icon(Icons.wifi, color: Colors.green);
      });
    } else if (ntState == NetworkConnectionState.disconnected && wsState == NetworkWebSocketState.disconnected) {
      setState(() {
        connectionIcon = const Icon(Icons.signal_wifi_connected_no_internet_4_outlined, color: Colors.red);
      });
    } else {
      setState(() {
        connectionIcon = const Icon(Icons.signal_wifi_statusbar_connected_no_internet_4_outlined, color: Colors.orange);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [Text("TITLE"), Text("Pulse - OK")],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, "/server_connection").then((value) => {checkConnection()});
          },
          icon: connectionIcon,
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.logout_outlined,
          ),
        ),
      ],
    );
  }
}
