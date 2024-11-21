import 'package:flutter/foundation.dart';
import 'package:tms/generated/infra/network_schemas/socket_protocol/server_socket_protocol.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/network/connectivity.dart';
import 'package:tms/network/db.dart';
import 'package:tms/network/http.dart';
import 'package:tms/network/ws.dart';

class NetworkController {
  final HttpController _httpController = HttpController();
  final WebsocketController _websocketController = WebsocketController();
  final DbController _dbController = DbController();

  // (http, ws, db)
  (NetworkConnectivity, NetworkConnectivity, NetworkConnectivity) innerNetworkStates() {
    return (_httpController.connectivity, _websocketController.connectivity, _dbController.connectivity);
  }

  NetworkConnectionState get state {
    var states = [
      _httpController.state,
      _websocketController.state,
      _dbController.state,
    ];

    NetworkConnectionState st;

    if (states.every((element) => element == NetworkConnectionState.connected)) {
      st = NetworkConnectionState.connected;
    } else {
      // disconnected
      st = NetworkConnectionState.disconnected;
    }

    return st;
  }

  Future<bool> _checkIp(String ip, int? port) async {
    var protocols = ["https", "http"];
    for (var p in protocols) {
      // TmsLocalStorageProvider().serverHttpProtocol = p;
      TmsLogger().d("Checking $p://$ip:$port");
      if (await _httpController.pulse("$p://$ip:$port")) {
        TmsLocalStorageProvider().serverHttpProtocol = p;
        TmsLocalStorageProvider().serverIp = ip;
        TmsLocalStorageProvider().serverPort = port ?? defaultServerPort;
        return true;
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }
    return false;
  }

  Future<bool> _heartbeat() async {
    // check stored address
    TmsLogger().d("Checking stored address");
    if (await _httpController.pulse(TmsLocalStorageProvider().serverAddress)) {
      TmsLogger().i("Connected to TMS server using stored address");
      return true;
    }

    // wait for half a second
    await Future.delayed(const Duration(milliseconds: 200));

    // check if ip is correct
    TmsLogger().d("Checking stored ip");
    if (await _checkIp(TmsLocalStorageProvider().serverIp, TmsLocalStorageProvider().serverPort)) {
      TmsLogger().i("Connected to TMS server (protocol changed)");
      return true;
    }

    await Future.delayed(const Duration(milliseconds: 200));

    // check web connection (web server is usually same as regular server)
    if (kIsWeb) {
      TmsLogger().d("Checking web server ip");
      String url = Uri.base.host;
      String host = Uri.parse(url).toString();
      TmsLogger().d("Checking host: $host");
      if (host.isNotEmpty) {
        // check with ip and stored port
        if (await _checkIp(host, TmsLocalStorageProvider().serverPort)) {
          TmsLogger().i("Connected to TMS server (web server)");
          return true;
        }

        // check with web ip and uri port
        if (await _checkIp(host, Uri.base.port)) {
          TmsLogger().i("Connected to TMS server (web server)");
          return true;
        }
      }
    }

    // couldn't find server pulse
    TmsLogger().e("Failed to connect to TMS server");
    return false;
  }

  Future<bool> _websocketConnect() async {
    return await _websocketController.connect(TmsLocalStorageProvider().wsConnectionString);
  }

  Future<void> init() async {
    // Write code to initialize the network controller
    await _dbController.init();
  }

  void dispose() {
    // Write code to dispose the network controller
    _dbController.dispose();
  }

  Future<bool> connect() async {
    if (await _heartbeat()) {
      if (await _httpController.connect()) {
        if (await _websocketConnect()) {
          await _dbController.connect();
          return true;
        }
      }
    }
    return false;
  }

  Future<void> disconnect() async {
    await _dbController.disconnect();
    await _httpController.disconnect();
    await _websocketController.disconnect();
  }

  // http
  Future<ServerResponse> httpPost(String route, dynamic body) => _httpController.httpPost(route, body);
  Future<ServerResponse> httpGet(String route) => _httpController.httpGet(route);
  Future<ServerResponse> httpDelete(String route, dynamic body) => _httpController.httpDelete(route, body);

  // websocket
  void subscribe(TmsServerSocketEvent event, TmsEventHandler handler) {
    _websocketController.subscribe(event, handler);
  }

  void unsubscribe(TmsServerSocketEvent event, TmsEventHandler handler) {
    _websocketController.unsubscribe(event, handler);
  }
}
