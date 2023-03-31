import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/pages/landing.dart';

class TmsHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = TmsHttpOverrides();
  runApp(MaterialApp(home: Landing()));
}
