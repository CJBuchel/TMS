import 'dart:async';

enum NetworkConnectionState {
  disconnected,
  connecting,
  connected,
}

typedef NetworkChangeHandler = Function(NetworkConnectionState state);

class NetworkConnectivity {
  NetworkChangeHandler? onNetworkChange;
  NetworkConnectionState _state;
  final _stateController = StreamController<NetworkConnectionState>.broadcast();

  NetworkConnectivity() : _state = NetworkConnectionState.disconnected {
    _stateController.stream.listen((state) {
      _state = state;
      onNetworkChange?.call(state);
    });
  }

  set state(NetworkConnectionState state) {
    _stateController.add(state);
  }

  NetworkConnectionState get state => _state;

  void dispose() {
    _stateController.close();
  }
}
