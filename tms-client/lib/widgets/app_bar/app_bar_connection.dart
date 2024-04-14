import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/network/controller/connectivity.dart';
import 'package:tms/providers/connection_provider.dart';

class TmsAppBarConnectionAction extends StatelessWidget {
  Icon _state2Wifi(NetworkConnectionState state) {
    switch (state) {
      case NetworkConnectionState.disconnected:
        return const Icon(Icons.signal_wifi_bad, color: Colors.red);
      case NetworkConnectionState.connecting:
        return const Icon(Icons.signal_wifi_statusbar_connected_no_internet_4, color: Colors.orange);
      case NetworkConnectionState.connected:
        return const Icon(Icons.signal_wifi_4_bar, color: Colors.white);
      default:
        return const Icon(Icons.signal_wifi_off, color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ConnectionProvider, NetworkConnectionState>(
      selector: (_, connectionProvider) => connectionProvider.state,
      builder: (_, connectionSate, __) => IconButton(
        onPressed: () {},
        icon: _state2Wifi(connectionSate),
      ),
    );
  }
}
