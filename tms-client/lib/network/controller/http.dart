import 'dart:convert';
import 'dart:io';

import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/network/controller/connectivity.dart';
import 'package:tms/schemas/networkSchema.dart' as nts;
import 'package:http/http.dart' as http;

typedef ServerResponse = (bool, int, dynamic); // success, status code, response

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
    if (addr.isEmpty) {
      _connectivity.state = NetworkConnectionState.disconnected;
      return false;
    }
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
        _connectivity.state = NetworkConnectionState.disconnected;
        return false;
      }
    } catch (e) {
      _connectivity.state = NetworkConnectionState.disconnected;
      return false;
    }
  }

  Future<bool> register() async {
    _connectivity.state = NetworkConnectionState.connecting;
    String addr = TmsLocalStorageProvider().serverAddress;
    var request = nts.RegisterRequest(
      username: TmsLocalStorageProvider().authUsername,
      password: TmsLocalStorageProvider().authPassword,
    );

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

      TmsLocalStorageProvider().wsConnectionString = res.url;
      TmsLocalStorageProvider().authToken = res.authToken;
      TmsLocalStorageProvider().uuid = res.uuid;
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
    String addr = TmsLocalStorageProvider().serverAddress;
    final response = await http.delete(
      Uri.parse("$addr/unregister/${TmsLocalStorageProvider().uuid}"),
      headers: {
        "X-Client-Id": TmsLocalStorageProvider().uuid,
        "X-Auth-Token": TmsLocalStorageProvider().authToken,
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

  // success, status code, response
  Future<ServerResponse> httpPost(String route, dynamic body) async {
    try {
      String addr = TmsLocalStorageProvider().serverAddress;
      final response = await http.post(
        Uri.parse("$addr$route"),
        body: jsonEncode(body),
        headers: {
          "X-Client-Id": TmsLocalStorageProvider().uuid,
          "X-Auth-Token": TmsLocalStorageProvider().authToken,
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        return (true, response.statusCode, jsonDecode(response.body));
      } else {
        TmsLogger().e("Failed to post to $route: ${response.statusCode}");
        return (false, response.statusCode, jsonDecode(response.body));
      }
    } catch (e) {
      TmsLogger().e("Caught failure. Failed to post to $route: $e");
      return (false, HttpStatus.internalServerError, e);
    }
  }

  Future<ServerResponse> httpGet(String route) async {
    try {
      String addr = TmsLocalStorageProvider().serverAddress;
      final response = await http.get(
        Uri.parse("$addr$route"),
        headers: {
          "X-Client-Id": TmsLocalStorageProvider().uuid,
          "X-Auth-Token": TmsLocalStorageProvider().authToken,
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        return (true, response.statusCode, jsonDecode(response.body));
      } else {
        TmsLogger().e("Failed to get from $route: ${response.statusCode}");
        return (false, response.statusCode, jsonDecode(response.body));
      }
    } catch (e) {
      TmsLogger().e("Caught failure. Failed to get from $route: $e");
      return (false, HttpStatus.internalServerError, e);
    }
  }

  Future<ServerResponse> httpDelete(String route, dynamic body) async {
    try {
      String addr = TmsLocalStorageProvider().serverAddress;
      final response = await http.delete(
        Uri.parse("$addr$route"),
        body: jsonEncode(body),
        headers: {
          "X-Client-Id": TmsLocalStorageProvider().uuid,
          "X-Auth-Token": TmsLocalStorageProvider().authToken,
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        return (true, response.statusCode, jsonDecode(response.body));
      } else {
        TmsLogger().e("Failed to delete from $route: ${response.statusCode}");
        return (false, response.statusCode, jsonDecode(response.body));
      }
    } catch (e) {
      TmsLogger().e("Caught failure. Failed to delete from $route: $e");
      return (false, HttpStatus.internalServerError, e);
    }
  }
}
