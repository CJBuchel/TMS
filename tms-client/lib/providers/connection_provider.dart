import 'package:flutter/material.dart';
import 'package:tms/network/controller/connectivity.dart';
import 'package:tms/network/controller/http.dart';
import 'package:tms/network/network.dart';

class ConnectionProvider with ChangeNotifier {
  NetworkConnectionState _httpState = NetworkConnectionState.disconnected;
  NetworkConnectionState _wsState = NetworkConnectionState.disconnected;
  NetworkConnectionState _dbState = NetworkConnectionState.disconnected;
  NetworkConnectionState _networkState = NetworkConnectionState.disconnected;

  bool _isConnected = false;

  // getters
  NetworkConnectionState get httpState => _httpState;
  NetworkConnectionState get wsState => _wsState;
  NetworkConnectionState get dbState => _dbState;
  // main line state
  NetworkConnectionState get state => _networkState;
  // main line getter
  bool get isConnected => _isConnected;

  // callbacks
  late final VoidCallback _httpListener;
  late final VoidCallback _wsListener;
  late final VoidCallback _dbListener;

  void _setStates() {
    bool http = _httpState == NetworkConnectionState.connected;
    bool ws = _wsState == NetworkConnectionState.connected;
    bool db = _dbState == NetworkConnectionState.connected;
    _networkState = Network().state;
    _isConnected = http && ws && db;
  }

  ConnectionProvider() {
    _httpListener = () {
      _httpState = Network().innerNetworkStates().$1.state;
      _setStates();
      notifyListeners();
    };
    _wsListener = () {
      _wsState = Network().innerNetworkStates().$2.state;
      _setStates();
      notifyListeners();
    };
    _dbListener = () {
      _dbState = Network().innerNetworkStates().$3.state;
      _setStates();
      notifyListeners();
    };

    Network().innerNetworkStates().$1.notifier.addListener(_httpListener);
    Network().innerNetworkStates().$2.notifier.addListener(_wsListener);
    Network().innerNetworkStates().$3.notifier.addListener(_dbListener);
  }

  @override
  void dispose() {
    Network().innerNetworkStates().$1.notifier.removeListener(_httpListener);
    Network().innerNetworkStates().$2.notifier.removeListener(_wsListener);
    Network().innerNetworkStates().$3.notifier.removeListener(_dbListener);
    super.dispose();
  }

  // network calls
  Future<ServerResponse> post(String route, dynamic body) => Network().networkPost(route, body);
  Future<ServerResponse> get(String route) => Network().networkGet(route);
  Future<ServerResponse> delete(String route, dynamic body) => Network().networkDelete(route, body);
}
