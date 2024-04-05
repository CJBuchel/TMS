import 'package:echo_tree_flutter/client/network_service.dart';
import 'package:echo_tree_flutter/echo_tree_flutter.dart';
import 'package:tms/constants.dart';
import 'package:tms/logger.dart';
import 'package:tms/network/controller/connectivity.dart';

class DbController {
  // final NetworkConnectivity _connectivity = NetworkConnectivity();
  NetworkConnectionState get state => _stateParser();

  NetworkConnectionState _stateParser() {
    switch (EchoTreeClient().state) {
      case EchoTreeConnection.connected:
        return NetworkConnectionState.connected;
      case EchoTreeConnection.connecting:
        return NetworkConnectionState.connecting;
      case EchoTreeConnection.disconnected:
        return NetworkConnectionState.disconnected;
      default:
        return NetworkConnectionState.disconnected;
    }
  }

  Future<void> connect() async {
    TmsLogger().d("Connecting to EchoTree DB...");
    await EchoTreeClient().connect(TmsLocalStorage().serverAddress);
  }

  Future<void> disconnect() async {
    TmsLogger().d("Disconnecting from EchoTree DB...");
    await EchoTreeClient().disconnect();
  }
}
