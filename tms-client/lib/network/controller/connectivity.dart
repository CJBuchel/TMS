import 'package:flutter/foundation.dart';

enum NetworkConnectionState { disconnected, connecting, connected }

class NetworkConnectivity {
  final ValueNotifier<NetworkConnectionState> _state = ValueNotifier(NetworkConnectionState.disconnected);

  set state(NetworkConnectionState v) => _state.value = v;
  NetworkConnectionState get state => _state.value;
}
