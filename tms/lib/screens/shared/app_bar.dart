import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'dart:ui' as ui;

import 'package:tms/network/network.dart';
import 'package:tms/network/ws.dart';

class TmsToolBar extends StatefulWidget with PreferredSizeWidget {
  NetworkConnectionState ntState;
  NetworkWebSocketState wsState;

  TmsToolBar({super.key, required this.ntState, required this.wsState});

  @override
  _TmsToolBarState createState() => _TmsToolBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TmsToolBarState extends State<TmsToolBar> {
  Icon connectionIcon = const Icon(Icons.signal_wifi_connected_no_internet_4_outlined, color: Colors.red);
  Text ntStatusText = const Text(
    "NO NT",
    style: TextStyle(color: Colors.red),
  );

  Text wsStatusText = const Text(
    "NO WS",
    style: TextStyle(color: Colors.red),
  );

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  // check the nt status
  void checkNT(NetworkConnectionState state) async {
    switch (state) {
      case NetworkConnectionState.disconnected:
        setState(() {
          ntStatusText = const Text(
            "NO NT",
            style: TextStyle(color: Colors.red),
          );
        });
        break;

      case NetworkConnectionState.connectedNoPulse:
        setState(() {
          ntStatusText = const Text(
            "NO PULSE",
            style: TextStyle(color: Colors.orange),
          );
        });
        break;

      case NetworkConnectionState.connected:
        setState(() {
          ntStatusText = const Text(
            "OK",
            style: TextStyle(color: Colors.green),
          );
        });
        break;
      default:
        setState(() {
          ntStatusText = const Text(
            "NO NT",
            style: TextStyle(color: Colors.red),
          );
        });
    }
  }

  void checkWS(NetworkWebSocketState state) async {
    switch (state) {
      case NetworkWebSocketState.disconnected:
        setState(() {
          wsStatusText = const Text(
            "NO WS",
            style: TextStyle(color: Colors.red),
          );
        });
        break;

      case NetworkWebSocketState.connectingEncryption:
        setState(() {
          wsStatusText = const Text(
            "ENC",
            style: TextStyle(color: Colors.orange),
          );
        });
        break;

      case NetworkWebSocketState.connected:
        setState(() {
          wsStatusText = const Text(
            "OK",
            style: TextStyle(color: Colors.green),
          );
        });
        break;
      default:
        setState(() {
          wsStatusText = const Text(
            "NO WS",
            style: TextStyle(color: Colors.red),
          );
        });
    }
  }

  // Quickly check the network connection and provide a color code to the network icon
  void checkNetwork(NetworkConnectionState ntState, NetworkWebSocketState wsState) async {
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

  void checkConnection() async {
    checkNetwork(widget.ntState, widget.wsState);
    checkNT(widget.ntState);
    checkWS(widget.wsState);
  }

  @override
  void didUpdateWidget(covariant TmsToolBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text("TITLE"),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [const Text("["), ntStatusText, const Text("/"), wsStatusText, const Text("]")],
          )
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            // _timer.cancel();
            // actionGoTo("/server_connection");
            Navigator.pushNamed(context, "/server_connection");
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
