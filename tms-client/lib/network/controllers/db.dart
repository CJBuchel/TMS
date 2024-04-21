import 'package:echo_tree_flutter/client/network_service.dart';
import 'package:echo_tree_flutter/echo_tree_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/network/controllers/connectivity.dart';

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
    var path = "tms";
    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory(); // might switch to support
      path = dir.path + "/tms";
    }
    await EchoTreeClient().connect(path, TmsLocalStorageProvider().serverAddress);
  }

  Future<void> disconnect() async {
    TmsLogger().d("Disconnecting from EchoTree DB...");
    await EchoTreeClient().disconnect();
  }
}
