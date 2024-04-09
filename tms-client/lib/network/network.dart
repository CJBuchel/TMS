import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tms/logger.dart';
import 'package:tms/network/controller/connectivity.dart';
import 'package:tms/network/controller/controller.dart';
import 'package:tms/network/controller/http.dart';
import 'package:tms/utils/blocking_loop_timer.dart';

typedef TypedServerResponse<T> = (bool, int, T?, String?);

class Network {
  static final Network _instance = Network._internal();
  final NetworkController _controller = NetworkController();
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

  ValueNotifier<NetworkConnectionState> get state => _controller.stateNotifier;
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
    if (_controller.state == NetworkConnectionState.disconnected) {
      TmsLogger().d("Reconnecting...");
      await _controller.connect();
    }
  }

  Future<void> start() async {
    _watchdogTimer?.start();
    await connect();
  }

  Future<void> stop() async {
    if (_watchdogTimer != null) {
      _watchdogTimer?.stop();
    }
    await disconnect();
  }

  // regular http
  Future<ServerResponse> networkPost(String route, dynamic body) => _controller.httpPost(route, body);
  Future<ServerResponse> networkGet(String route) => _controller.httpGet(route);
  Future<ServerResponse> networkDelete(String route, dynamic body) => _controller.httpDelete(route, body);
}
