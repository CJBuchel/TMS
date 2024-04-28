import 'dart:convert';
import 'dart:io';

import 'package:tms/network/http_client.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/network/connectivity.dart';
import 'package:tms/schemas/network_schema.dart' as nts;

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

  final _client = TmsHttpClient.create();

  Future<bool> pulse(String addr) async {
    if (addr.isEmpty) {
      _connectivity.state = NetworkConnectionState.disconnected;
      return false;
    }
    try {
      var response = await _client.get(
        Uri.parse("$addr/pulse"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      TmsLogger().d("Pulse response: ${response.statusCode}");

      if (response.statusCode == HttpStatus.ok) {
        return true;
      } else {
        _connectivity.state = NetworkConnectionState.disconnected;
        return false;
      }
    } catch (e) {
      _connectivity.state = NetworkConnectionState.disconnected;
      TmsLogger().e("Caught failure. Failed to pulse: $e");
      return false;
    }
  }

  Future<bool> connect() async {
    _connectivity.state = NetworkConnectionState.connecting;
    String addr = TmsLocalStorageProvider().serverAddress;
    var request = nts.RegisterRequest(
      username: TmsLocalStorageProvider().authUsername,
      password: TmsLocalStorageProvider().authPassword,
    );

    var response = await _client.post(
      Uri.parse("$addr/register"),
      body: jsonEncode(request.toJson()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      TmsLogger().d("Registered with TMS server");
      nts.RegisterResponse res = nts.RegisterResponse.fromJson(jsonDecode(response.body));

      TmsLocalStorageProvider().serverExternalIp = res.serverIp;
      TmsLocalStorageProvider().wsConnectionString = res.url;
      TmsLocalStorageProvider().authToken = res.authToken;
      TmsLocalStorageProvider().uuid = res.uuid;
      TmsLocalStorageProvider().authRoles = res.roles;
      _connectivity.state = NetworkConnectionState.connected;

      return true;
    } else {
      var m = HttpStatusToMessage().getMessage(response.statusCode);
      TmsLogger().w("Failed to register with TMS server: $m");
      _connectivity.state = NetworkConnectionState.disconnected;
      return false;
    }
  }

  Future<bool> disconnect() async {
    String addr = TmsLocalStorageProvider().serverAddress;
    final response = await _client.delete(
      Uri.parse("$addr/register/${TmsLocalStorageProvider().uuid}"),
      headers: {
        "X-Client-Id": TmsLocalStorageProvider().uuid,
        "X-Auth-Token": TmsLocalStorageProvider().authToken,
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      TmsLogger().d("Unregistered with TMS server");
      _connectivity.state = NetworkConnectionState.disconnected;
      _client.close();
      return true;
    } else {
      var m = HttpStatusToMessage().getMessage(response.statusCode);
      TmsLogger().w("Failed to unregister with TMS server: $m");
      _connectivity.state = NetworkConnectionState.disconnected;
      _client.close();
      return false;
    }
  }

  // success, status code, response
  Future<ServerResponse> httpPost(String route, dynamic body) async {
    try {
      String addr = TmsLocalStorageProvider().serverAddress;
      final response = await _client.post(
        Uri.parse("$addr$route"),
        body: jsonEncode(body),
        headers: {
          "X-Client-Id": TmsLocalStorageProvider().uuid,
          "X-Auth-Token": TmsLocalStorageProvider().authToken,
          "Content-Type": "application/json",
        },
      );

      dynamic responseBody;
      if (response.body.isNotEmpty) {
        try {
          responseBody = jsonDecode(response.body);
        } catch (e) {
          TmsLogger().w("Failed to decode response body: $e, using raw response");
          responseBody = response.body;
        }
      }

      if (response.statusCode == HttpStatus.ok) {
        return (true, response.statusCode, responseBody);
      } else {
        TmsLogger().e("Failed to post to $route: ${response.statusCode}");
        return (false, response.statusCode, responseBody);
      }
    } catch (e) {
      TmsLogger().e("Caught failure. Failed to post to $route: $e");
      return (false, HttpStatus.internalServerError, e);
    }
  }

  Future<ServerResponse> httpGet(String route) async {
    try {
      String addr = TmsLocalStorageProvider().serverAddress;
      final response = await _client.get(
        Uri.parse("$addr$route"),
        headers: {
          "X-Client-Id": TmsLocalStorageProvider().uuid,
          "X-Auth-Token": TmsLocalStorageProvider().authToken,
          "Content-Type": "application/json",
        },
      );

      dynamic responseBody;
      if (response.body.isNotEmpty) {
        try {
          responseBody = jsonDecode(response.body);
        } catch (e) {
          TmsLogger().w("Failed to decode response body: $e, using raw response");
          responseBody = response.body;
        }
      }

      if (response.statusCode == HttpStatus.ok) {
        return (true, response.statusCode, responseBody);
      } else {
        TmsLogger().e("Failed to get from $route: ${response.statusCode}");
        return (false, response.statusCode, responseBody);
      }
    } catch (e) {
      TmsLogger().e("Caught failure. Failed to get from $route: $e");
      return (false, HttpStatus.internalServerError, e);
    }
  }

  Future<ServerResponse> httpDelete(String route, dynamic body) async {
    try {
      String addr = TmsLocalStorageProvider().serverAddress;
      final response = await _client.delete(
        Uri.parse("$addr$route"),
        body: jsonEncode(body),
        headers: {
          "X-Client-Id": TmsLocalStorageProvider().uuid,
          "X-Auth-Token": TmsLocalStorageProvider().authToken,
          "Content-Type": "application/json",
        },
      );

      dynamic responseBody;
      if (response.body.isNotEmpty) {
        try {
          responseBody = jsonDecode(response.body);
        } catch (e) {
          TmsLogger().w("Failed to decode response body: $e, using raw response");
          responseBody = response.body;
        }
      }

      if (response.statusCode == HttpStatus.ok) {
        return (true, response.statusCode, responseBody);
      } else {
        TmsLogger().e("Failed to delete from $route: ${response.statusCode}");
        return (false, response.statusCode, responseBody);
      }
    } catch (e) {
      TmsLogger().e("Caught failure. Failed to delete from $route: $e");
      return (false, HttpStatus.internalServerError, e);
    }
  }
}
