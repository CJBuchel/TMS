import 'dart:io';

import 'package:tms/generated/infra/network_schemas/register_requests.dart';
import 'package:tms/network/http_client.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/utils/http_status_to_message.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/network/connectivity.dart';

typedef ServerResponse = (bool, int, String); // success, status code, response

class HttpController {
  final NetworkConnectivity _connectivity = NetworkConnectivity();
  NetworkConnectionState get state => _connectivity.state;
  NetworkConnectivity get connectivity => _connectivity;

  final _client = TmsHttpClient.create();

  Map<String, String> get authHeaders {
    return {
      "X-Client-Id": TmsLocalStorageProvider().uuid,
      "X-Auth-Token": TmsLocalStorageProvider().authToken,
    };
  }

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
    var request = RegisterRequest(
      username: TmsLocalStorageProvider().authUsername,
      password: TmsLocalStorageProvider().authPassword,
    );

    var response = await _client.post(
      Uri.parse("$addr/register"),
      body: request.toJsonString(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      TmsLogger().d("Registered with TMS server");
      RegisterResponse res = RegisterResponse.fromJsonString(json: response.body);

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
        ...authHeaders,
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
  Future<ServerResponse> httpPost(String route, dynamic body, {bool retry = true}) async {
    try {
      String addr = TmsLocalStorageProvider().serverAddress;
      final response = await _client.post(
        Uri.parse("$addr$route"),
        body: body,
        headers: {
          ...authHeaders,
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        return (true, response.statusCode, response.body);
      } else if (response.statusCode == HttpStatus.networkAuthenticationRequired && retry) {
        TmsLogger().e("Failed to post to $route: Network Authentication Required (511) - retrying");
        await connect();
        return httpPost(route, body, retry: false);
      } else {
        String message = HttpStatusToMessage().getMessage(response.statusCode);
        TmsLogger().e("Failed to post to $route: $message");
        return (false, response.statusCode, response.body);
      }
    } catch (e) {
      TmsLogger().e("Caught failure. Failed to post to $route: $e");
      return (false, HttpStatus.internalServerError, e.toString());
    }
  }

  Future<ServerResponse> httpGet(String route, {bool retry = true}) async {
    try {
      String addr = TmsLocalStorageProvider().serverAddress;
      final response = await _client.get(
        Uri.parse("$addr$route"),
        headers: {
          ...authHeaders,
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        return (true, response.statusCode, response.body);
      } else if (response.statusCode == HttpStatus.networkAuthenticationRequired && retry) {
        TmsLogger().e("Failed to get from $route: Network Authentication Required (511) - retrying");
        await connect();
        return httpGet(route, retry: false);
      } else {
        String message = HttpStatusToMessage().getMessage(response.statusCode);
        TmsLogger().e("Failed to get from $route: $message");
        return (false, response.statusCode, response.body);
      }
    } catch (e) {
      TmsLogger().e("Caught failure. Failed to get from $route: $e");
      return (false, HttpStatus.internalServerError, e.toString());
    }
  }

  Future<ServerResponse> httpDelete(String route, dynamic body, {bool retry = true}) async {
    try {
      String addr = TmsLocalStorageProvider().serverAddress;
      final response = await _client.delete(
        Uri.parse("$addr$route"),
        body: body,
        headers: {
          ...authHeaders,
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        return (true, response.statusCode, response.body);
      } else if (response.statusCode == HttpStatus.networkAuthenticationRequired && retry) {
        TmsLogger().e("Failed to delete from $route: Network Authentication Required (511) - retrying");
        await connect();
        return httpDelete(route, body, retry: false);
      } else {
        String message = HttpStatusToMessage().getMessage(response.statusCode);
        TmsLogger().e("Failed to delete from $route: $message");
        return (false, response.statusCode, response.body);
      }
    } catch (e) {
      TmsLogger().e("Caught failure. Failed to delete from $route: $e");
      return (false, HttpStatus.internalServerError, e.toString());
    }
  }
}
