import 'package:flutter/foundation.dart';
import 'package:tms/constants.dart';
import 'package:tms/logger.dart';
import 'package:tms/network/controller/connectivity.dart';
import 'package:tms/network/controller/http.dart';
import 'package:tms/network/controller/mdns.dart';
import 'package:tms/network/controller/ws.dart';

class NetworkController {
  final HttpController _httpController;
  final MdnsController _mdnsController;
  final WebSocketController _webSocketController;
  final NetworkConnectivity _connectionState;

  NetworkController(NetworkConnectivity connectionState)
      : _httpController = HttpController(),
        _mdnsController = MdnsController(),
        _connectionState = connectionState,
        _webSocketController = WebSocketController();

  Future<bool> _checkIp(String ip) async {
    var protocols = ["https", "http"];
    for (var p in protocols) {
      TmsLocalStorage().serverHttpProtocol = p;
      if (await _httpController.pulse(TmsLocalStorage().serverAddress)) {
        return true;
      }
    }

    return false;
  }

  Future<bool> _heartbeat() async {
    // check stored address
    if (await _httpController.pulse(TmsLocalStorage().serverAddress)) {
      TmsLogger().d("Connected to TMS server using stored address");
      return true;
    }

    // check if ip is correct
    if (await _checkIp(TmsLocalStorage().serverIp)) {
      TmsLogger().d("Connected to TMS server (protocol changed)");
      return true;
    }

    // check web connection (web server is usually same as regular server)
    if (kIsWeb) {
      String url = Uri.base.host;
      String host = Uri.parse(url).toString();
      if (host.isNotEmpty) {
        if (await _checkIp(host)) {
          TmsLocalStorage().serverIp = host;
          TmsLogger().d("Connected to TMS server (web server)");
          return true;
        }
      }
    }

    // find server using mdns
    var (found, ip) = await _mdnsController.findServer();
    if (found) {
      TmsLocalStorage().serverIp = ip;
      if (await _checkIp(ip)) {
        return true;
      }
    }

    // couldn't find server pulse
    return false;
  }

  Future<bool> _websocketConnect() async {
    return await _webSocketController.connect(TmsLocalStorage().wsConnectionString);
  }

  Future<bool> connect() async {
    _connectionState.state = NetworkConnectionState.connecting;
    if (await _heartbeat()) {
      if (await _httpController.register()) {
        if (await _websocketConnect()) {
          _connectionState.state = NetworkConnectionState.connected;
          return true;
        }
      }
    }

    _connectionState.state = NetworkConnectionState.disconnected;
    return false;
  }

  Future<void> disconnect() async {
    await _httpController.unregister();
    await _webSocketController.disconnect();
    _connectionState.state = NetworkConnectionState.disconnected;
  }

  void onNetworkStateChange(NetworkChangeHandler handler) {
    _connectionState.onNetworkChange = handler;
  }
}
