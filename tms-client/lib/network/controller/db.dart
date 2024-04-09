import 'package:echo_tree_flutter/client/network_service.dart';
import 'package:echo_tree_flutter/echo_tree_flutter.dart';
import 'package:tms/local_storage.dart';
import 'package:tms/logger.dart';
import 'package:tms/network/controller/connectivity.dart';

class DbController {
  final NetworkConnectivity _connectivity = NetworkConnectivity();
  NetworkConnectionState get state => _stateParser();
  NetworkConnectivity get connectivity => _connectivity;

  NetworkConnectionState _stateParser() {
    NetworkConnectionState st;

    switch (EchoTreeClient().state) {
      case EchoTreeConnection.connected:
        st = NetworkConnectionState.connected;
        break;
      case EchoTreeConnection.connecting:
        st = NetworkConnectionState.connecting;
        break;
      case EchoTreeConnection.disconnected:
        st = NetworkConnectionState.disconnected;
        break;
      default:
        st = NetworkConnectionState.disconnected;
    }

    if (st != _connectivity.state) {
      _connectivity.state = st;
    }

    return st;
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
