import 'package:flutter/foundation.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/network/controller/connectivity.dart';
import 'package:tms/network/controller/db.dart';
import 'package:tms/network/controller/http.dart';
import 'package:tms/network/controller/mdns.dart';
import 'package:tms/network/controller/ws.dart';

class NetworkController {
  final HttpController _httpController = HttpController();
  final MdnsController _mdnsController = MdnsController();
  final WebsocketController _websocketController = WebsocketController();
  final DbController _dbController = DbController();

  final ValueNotifier<NetworkConnectionState> _stateNotifier = ValueNotifier(NetworkConnectionState.disconnected);
  ValueNotifier<NetworkConnectionState> get stateNotifier => _stateNotifier;

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
    } else if (states.contains(NetworkConnectionState.connecting)) {
      st = NetworkConnectionState.connecting;
    } else {
      // disconnected
      st = NetworkConnectionState.disconnected;
    }

    if (st != _stateNotifier.value) {
      _stateNotifier.value = st;
    }

    return st;
  }

  Future<bool> _checkIp(String ip) async {
    var protocols = ["https", "http"];
    for (var p in protocols) {
      // TmsLocalStorageProvider().serverHttpProtocol = p;
      if (await _httpController.pulse("$p://$ip:$serverPort")) {
        TmsLocalStorageProvider().serverHttpProtocol = p;
        TmsLocalStorageProvider().serverIp = ip;
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
    if (await _checkIp(TmsLocalStorageProvider().serverIp)) {
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
        if (await _checkIp(host)) {
          TmsLogger().i("Connected to TMS server (web server)");
          return true;
        }
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));

    // find server using mdns
    if (!kIsWeb) {
      TmsLogger().d("Finding server using mdns");
      var (found, ip) = await _mdnsController.findServer();
      if (found) {
        TmsLocalStorageProvider().serverIp = ip;
        if (await _checkIp(ip)) {
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

  Future<bool> connect() async {
    if (await _heartbeat()) {
      if (await _httpController.register()) {
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
    await _httpController.unregister();
    await _websocketController.disconnect();
  }

  Future<ServerResponse> httpPost(String route, dynamic body) => _httpController.httpPost(route, body);
  Future<ServerResponse> httpGet(String route) => _httpController.httpGet(route);
  Future<ServerResponse> httpDelete(String route, dynamic body) => _httpController.httpDelete(route, body);
}
