import 'dart:async';
import 'package:tms/generated/infra/network_schemas/socket_protocol/server_socket_protocol.dart';
import 'package:tms/network/ws.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/network/connectivity.dart';
import 'package:tms/network/network_controller.dart';
import 'package:tms/network/http.dart';
import 'package:tms/utils/blocking_loop_timer.dart';

class Network {
  static final Network _instance = Network._internal();
  final NetworkController _controller = NetworkController();
  bool _running = false;
  BlockingLoopTimer? _watchdogTimer;
  Network._internal() {
    _watchdogTimer = BlockingLoopTimer(
      interval: const Duration(seconds: 5),
      callback: _checkConnection,
    );
  }

  factory Network() {
    return _instance;
  }

  NetworkConnectionState get state => _controller.state;

  // (http, ws, db)
  (NetworkConnectivity, NetworkConnectivity, NetworkConnectivity) innerNetworkStates() {
    return _controller.innerNetworkStates();
  }

  Future<void> connect() async {
    await _controller.connect();
  }

  Future<void> disconnect() async {
    await _controller.disconnect();
  }

  Future<void> _checkConnection() async {
    // @TODO future me, after connection is established and then loses signal, http remains connected, therefore the reconnect watchdog is never triggered.
    // The quick fix is to keep reconnecting the http connection until it is connected. (We should be checking if it's "connecting", instead of just not connected)
    if (_controller.state != NetworkConnectionState.connected) {
      TmsLogger().d("Reconnecting...");
      await _controller.connect();
    }
  }

  Future<void> start() async {
    if (_running) {
      return;
    }
    await _controller.init();
    _watchdogTimer?.start();
    await connect();
    _running = true;
  }

  Future<void> stop() async {
    if (!_running) {
      return;
    }
    _controller.dispose();
    if (_watchdogTimer != null) {
      _watchdogTimer?.stop();
    }
    await disconnect();
    _running = false;
  }

  // regular http
  Future<ServerResponse> networkPost(String route, dynamic body) => _controller.httpPost(route, body);
  Future<ServerResponse> networkGet(String route) => _controller.httpGet(route);
  Future<ServerResponse> networkDelete(String route, dynamic body) => _controller.httpDelete(route, body);

  void subscribe(TmsServerSocketEvent event, TmsEventHandler handler) {
    _controller.subscribe(event, handler);
  }

  void unsubscribe(TmsServerSocketEvent event, TmsEventHandler handler) {
    _controller.unsubscribe(event, handler);
  }
}
