import 'dart:convert';
import 'dart:io';

import 'package:tms/constants.dart';
import 'package:tms/logger.dart';
import 'package:tms/network/controller/connectivity.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schemas/network.dart' as nts;
import 'package:http/http.dart' as http;

class HttpStatusToMessage {
  static final HttpStatusToMessage _instance = HttpStatusToMessage._internal();
  HttpStatusToMessage._internal();

  factory HttpStatusToMessage() {
    return _instance;
  }

  String getMessage(int code) {
    var message = "";
    switch (code) {
      case HttpStatus.ok:
        message = "OK";
      case HttpStatus.badRequest:
        message = "Bad Request";
      case HttpStatus.unauthorized:
        message = "Unauthorized";
      case HttpStatus.forbidden:
        message = "Forbidden";
      case HttpStatus.notFound:
        message = "Not Found";
      case HttpStatus.internalServerError:
        message = "Internal Server Error";
      default:
        message = "Unknown";
    }

    message = "$message ($code)";
    return message;
  }
}

class HttpController {
  final NetworkConnectivity _connectivity = NetworkConnectivity();
  NetworkConnectionState get state => _connectivity.state;
  NetworkConnectivity get connectivity => _connectivity;

  Future<bool> pulse(String addr) async {
    try {
      var response = await http.get(
        Uri.parse("$addr/pulse"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> register() async {
    String addr = TmsLocalStorage().serverAddress;
    var request = nts.RegisterRequest();

    var response = await http.post(
      Uri.parse("$addr/register"),
      body: jsonEncode(request.toJson()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      TmsLogger().d("Registered with TMS server");
      nts.RegisterResponse res = nts.RegisterResponse.fromJson(jsonDecode(response.body));

      TmsLocalStorage().wsConnectionString = res.url;
      TmsLocalStorage().authToken = res.authToken;
      TmsLocalStorage().uuid = res.uuid;
      _connectivity.state = NetworkConnectionState.connected;

      return true;
    } else {
      var m = HttpStatusToMessage().getMessage(response.statusCode);
      TmsLogger().w("Failed to register with TMS server: $m");
      _connectivity.state = NetworkConnectionState.disconnected;
      return false;
    }
  }

  Future<bool> unregister() async {
    String addr = TmsLocalStorage().serverAddress;
    final response = await http.delete(
      Uri.parse("$addr/unregister/${TmsLocalStorage().uuid}"),
      headers: {
        "X-Client-Id": TmsLocalStorage().uuid,
        "X-Auth-Token": TmsLocalStorage().authToken,
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      TmsLogger().d("Unregistered with TMS server");
      _connectivity.state = NetworkConnectionState.disconnected;
      return true;
    } else {
      var m = HttpStatusToMessage().getMessage(response.statusCode);
      TmsLogger().w("Failed to unregister with TMS server: $m");
      _connectivity.state = NetworkConnectionState.disconnected;
      return false;
    }
  }
}
