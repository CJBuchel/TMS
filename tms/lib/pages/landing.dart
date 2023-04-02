import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:tms/schema/tms-schema.dart';

class Landing extends StatefulWidget {
  Landing({super.key});

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final channel = WebSocketChannel.connect(Uri.parse("wss://localhost:2121/echo"));

    final check = TmsSchema(myInt: Test(testInt: 0));

    channel.stream.listen((data) {
      print(data);
    }, onError: (error) {
      print(error);
    });
  }

  final info = NetworkInfo();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text("Landing Page"),
    );
  }
}
