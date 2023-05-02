import 'dart:async';

import 'package:tms/constants.dart';
import 'package:tms/network/network.dart';
import 'package:tms/screens/connection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tms/screens/screen_selector.dart';
import 'package:tms/screens/shared/tool_bar.dart';

class TMSApp extends StatefulWidget {
  TMSApp({super.key});

  @override
  _TMSAppState createState() => _TMSAppState();
}

class _TMSAppState extends State<TMSApp> {
  Timer _connectionTimer = Timer(const Duration(), () {});
  TmsToolBar tmsToolBar = TmsToolBar();

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

    Network.disconnect();
  }

  Future<void> checkConnection() async {
    Network.checkConnection().then((ok) {
      if (!ok) {
        Network.findServer().then((found) {
          if (found) {
            Network.connect();
          }
        });
      }
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
        '/': (context) => ScreenSelector(),
        '/server_connection': (context) => Connection(),
      },
    );
  }
}

void main() {
  runApp(TMSApp());
}
