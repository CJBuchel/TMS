import 'package:echo_tree_flutter/client/network_service.dart';
import 'package:echo_tree_flutter/echo_tree_flutter.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/network/connectivity.dart';

class DbController {
  final NetworkConnectivity _connectivity = NetworkConnectivity();
  NetworkConnectionState get state => _connectivity.state;
  NetworkConnectivity get connectivity => _connectivity;

  NetworkConnectionState _stateParser() {
    NetworkConnectionState st;

    switch (EchoTreeClient().state.value) {
      case EchoTreeConnection.connected:
        st = NetworkConnectionState.connected;
        break;
      case EchoTreeConnection.disconnected:
        st = NetworkConnectionState.disconnected;
        break;
      default:
        st = NetworkConnectionState.disconnected;
    }

    return st;
  }

  void _listener() {
    _connectivity.state = _stateParser();
  }

  Future<void> init() async {
    EchoTreeClient().state.addListener(_listener);
  }

  void dispose() {
    EchoTreeClient().state.removeListener(_listener);
  }

  Future<void> connect() async {
    TmsLogger().d("Connecting to EchoTree DB...");
    Map<String, String> roles = Map<String, String>.fromEntries(
      TmsLocalStorageProvider().authRoles.map((e) => MapEntry(e.roleId, e.password)),
    );

    try {
      await EchoTreeClient().connect(TmsLocalStorageProvider().serverAddress, roles: roles);
    } catch (e) {
      TmsLogger().e("Error connecting to EchoTree DB: $e");
    }

    var state = _stateParser();
    TmsLogger().i("State: $state");
  }

  Future<void> disconnect() async {
    try {
      TmsLogger().d("Disconnecting from EchoTree DB...");
      await EchoTreeClient().disconnect();
    } catch (e) {
      TmsLogger().e("Error disconnecting from EchoTree DB: $e");
    }
  }
}
