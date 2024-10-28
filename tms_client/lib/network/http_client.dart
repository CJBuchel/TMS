import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:io';

import 'package:tms/utils/logger.dart';

class TmsHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class TmsHttpClient extends http.BaseClient {
  final http.Client _innerClient;

  TmsHttpClient(this._innerClient);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return _innerClient.send(request);
  }

  // factory
  factory TmsHttpClient.create() {
    if (kIsWeb) {
      return TmsHttpClient(http.Client());
    } else {
      TmsLogger().w("Using custom HttpClient for non-web platform");
      var ioClient = HttpClient();
      ioClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return TmsHttpClient(new IOClient(ioClient));
    }
  }
}
