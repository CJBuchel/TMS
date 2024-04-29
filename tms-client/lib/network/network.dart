import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:tms/network/service_discovery.dart';
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
    if (_controller.state == NetworkConnectionState.disconnected) {
      TmsLogger().d("Reconnecting...");
      // startup network discovery (non web)
      if (!kIsWeb) {
        await ServiceDiscoveryController().start();
      }
      await _controller.connect();
    } else {
      if (!kIsWeb) {
        await ServiceDiscoveryController().stop();
      }
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
}
