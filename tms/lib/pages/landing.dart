import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';

class Landing extends StatefulWidget {
  const Landing({super.key});

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  final info = NetworkInfo();
  // Future<http.Response> fetchEcho() {
  //   return http.get(Uri.parse('http://127.0.0.1:2121/'));
  // }

  // void serverFind() {
  //   info.getWifiIP().then((value) async {
  //     final ipArr = value?.split('.');

  //     var client = http.Client();
  //     for (var i = 1; i < 255; i++) {
  //       String bufferIP =
  //           'http://${ipArr?[0]}.${ipArr?[1]}.${ipArr?[2]}.$i:2121/';

  //       try {
  //         var response = await client.get(Uri.parse(bufferIP));
  //         print(response);
  //       } catch (e) {
  //         print(e);
  //       }
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // fetchEcho();
    // serverFind();
    return const Scaffold(
      body: Text("Landing Page"),
    );
  }
}
