import 'dart:async';

import 'package:tms/constants.dart';
import 'package:tms/network/network.dart';
import 'package:tms/network/ws.dart';
import 'package:tms/screens/shared/app_bar.dart';
import 'package:tms/screens/connection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tms/screens/screen_selector.dart';

class TMSApp extends StatefulWidget {
  TMSApp({super.key});

  @override
  _TMSAppState createState() => _TMSAppState();
}

class _TMSAppState extends State<TMSApp> {
  Timer _connectionTimer = Timer(const Duration(), () {});
  TmsToolBar _tmsToolBar = TmsToolBar(ntState: NetworkConnectionState.disconnected, wsState: NetworkWebSocketState.disconnected);

  Future<void> startConnection() async {
    print("Network Started");
    checkConnection();
    setState(() {
      _connectionTimer = Timer.periodic(watchDogTime, (timer) async {
        await checkConnection();
      });
    });
  }

  Future<void> stopConnection() async {
    print("Network Stopped");
    if (_connectionTimer.isActive) {
      _connectionTimer.cancel();
    }

    NetworkWebSocket.disconnect();
  }

  Future<void> checkConnection() async {
    // @TODO, reconnect on fail
    var ntState = await Network.getPulse();
    var wsState = await NetworkWebSocket.getState();
    setState(() {
      _tmsToolBar = TmsToolBar(ntState: ntState, wsState: wsState);
    });
  }

  @override
  void initState() {
    super.initState();
    print("Initialized main state");
    startConnection();
  }

  @override
  void dispose() {
    super.dispose();
    stopConnection();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'TMS Client',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
      ),

      // Main Router
      routes: {
        '/': (context) => ScreenSelector(toolBar: _tmsToolBar),
        '/server_connection': (context) => Connection(toolBar: _tmsToolBar),
      },
    );
  }
}

void main() {
  runApp(TMSApp());
}
