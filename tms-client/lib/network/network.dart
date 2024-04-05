import 'dart:async';
import 'package:tms/logger.dart';
import 'package:tms/network/controller/connectivity.dart';
import 'package:tms/network/controller/controller.dart';

class Network {
  static final Network _instance = Network._internal();
  final NetworkController _controller = NetworkController();
  Timer? _watchdogTimer;
  Network._internal();

  factory Network() {
    return _instance;
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
    // start it up again
    _startWatchdog();
  }

  void _startWatchdog() {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer(const Duration(seconds: 5), _checkConnection);
  }

  Future<void> start() async {
    _startWatchdog();
    await connect();
  }

  Future<void> stop() async {
    if (_watchdogTimer != null) {
      _watchdogTimer?.cancel();
      _watchdogTimer = null;
    }
    await disconnect();
  }
}
