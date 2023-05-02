import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'dart:ui' as ui;

import 'package:tms/network/http.dart';
import 'package:tms/network/network.dart';
import 'package:tms/network/ws.dart';
import 'package:tuple/tuple.dart';

class TmsToolBar extends StatefulWidget with PreferredSizeWidget {
  Tuple2<NetworkHttpConnectionState, NetworkWebSocketState> networkState = const Tuple2(
    NetworkHttpConnectionState.disconnected,
    NetworkWebSocketState.disconnected,
  );

  TmsToolBar({super.key}) {
    Network.getState().then((state) => networkState = state);
  }

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
  void checkHTTP(NetworkHttpConnectionState state) async {
    switch (state) {
      case NetworkHttpConnectionState.disconnected:
        setState(() {
          ntStatusText = const Text(
            "NO NT",
            style: TextStyle(color: Colors.red),
          );
        });
        break;

      case NetworkHttpConnectionState.connectedNoPulse:
        setState(() {
          ntStatusText = const Text(
            "NO PULSE",
            style: TextStyle(color: Colors.orange),
          );
        });
        break;

      case NetworkHttpConnectionState.connected:
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
  void checkNetwork(Tuple2<NetworkHttpConnectionState, NetworkWebSocketState> ntStates) async {
    if (ntStates.item1 == NetworkHttpConnectionState.connected && ntStates.item2 == NetworkWebSocketState.connected) {
      setState(() {
        connectionIcon = const Icon(Icons.wifi, color: Colors.green);
      });
    } else if (ntStates.item1 == NetworkHttpConnectionState.disconnected && ntStates.item2 == NetworkWebSocketState.disconnected) {
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
    checkNetwork(widget.networkState);
    checkHTTP(widget.networkState.item1);
    checkWS(widget.networkState.item2);
  }

  @override
  void didUpdateWidget(covariant TmsToolBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    checkConnection();
  }

  List<Widget> appTitle() {
    if (widget.networkState.item1 == NetworkHttpConnectionState.connected && widget.networkState.item2 == NetworkHttpConnectionState.connected) {
      return [const Text("TITLE")];
    } else {
      return [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [const Text("["), ntStatusText, const Text("/"), wsStatusText, const Text("]")],
        )
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: appTitle()),
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
