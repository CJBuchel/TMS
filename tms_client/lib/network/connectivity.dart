import 'package:flutter/foundation.dart';

enum NetworkConnectionState { disconnected, connected }

class NetworkConnectivity {
  final ValueNotifier<NetworkConnectionState> _state = ValueNotifier(NetworkConnectionState.disconnected);

  ValueNotifier<NetworkConnectionState> get notifier => _state;

  set state(NetworkConnectionState v) => _state.value = v;
  NetworkConnectionState get state => _state.value;
}
