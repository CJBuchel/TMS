import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/pages/landing.dart';

// import 'package:path/path.dart' show dirname, join, normalize;

// String _scriptPath() {
//   var script = Platform.script.toString();
//   if (script.startsWith("file://")) {
//     script = script.substring(7);
//   } else {
//     final idx = script.indexOf("file:/");
//     script = script.substring(idx + 5);
//   }

//   return script;
// }

class TmsHttpOverrides extends HttpOverrides {
  // @override
  // HttpClient createHttpClient(SecurityContext? context) {
  //   return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  // }
}

void main() {
  // HttpOverrides.global = TmsHttpOverrides();
  runApp(MaterialApp(home: Landing()));
}
