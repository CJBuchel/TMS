import 'dart:async';
import 'package:tms/logger.dart';
import 'package:tms/network/controller/connectivity.dart';
import 'package:tms/network/controller/controller.dart';

class Network {
  static final Network _instance = Network._internal();
  final NetworkConnectivity _connectivity = NetworkConnectivity();
  NetworkController? _controller;
  bool _running = false;
  Network._internal();

  factory Network() {
    _instance._controller = NetworkController(_instance._connectivity);
    _instance._connectivity.onNetworkChange = _instance._checkConnection;
    return _instance;
  }

  void _checkConnection(NetworkConnectionState state) {
    if (!_running) return;
    TmsLogger().d("Network state changed to $state");
    if (state == NetworkConnectionState.disconnected) {
      _controller?.connect().then((connected) {
        if (!connected) {
          Future.delayed(const Duration(seconds: 5), () {
            // trigger state change, will reconnect
            _connectivity.state = NetworkConnectionState.disconnected;
          });
        }
      });
    }
  }

  Future<void> connect() async {
    await _controller?.connect();
  }

  Future<void> disconnect() async {
    await _controller?.disconnect();
  }

  Future<void> start() async {
    if (_running) return;
    _running = true;
    await connect();
  }

  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    await disconnect();
  }
}
