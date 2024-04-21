import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/network/controllers/connectivity.dart';
import 'package:tms/providers/connection_provider.dart';

class TmsAppBarTitle extends StatelessWidget {
  TmsAppBarTitle({super.key});

  Text _state2Text(NetworkConnectionState state) {
    switch (state) {
      case NetworkConnectionState.disconnected:
        return const Text("DC", style: TextStyle(color: Colors.red));
      case NetworkConnectionState.connecting:
        return const Text("CNT", style: TextStyle(color: Colors.orange));
      case NetworkConnectionState.connected:
        return const Text("OK", style: TextStyle(color: Colors.green));
      default:
        return const Text("N/A");
    }
  }

  Widget _stateTitleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("["),
        Selector<ConnectionProvider, NetworkConnectionState>(
          selector: (_, connectionProvider) => connectionProvider.httpState,
          builder: (_, state, __) => _state2Text(state),
        ),
        const Text("|"),
        Selector<ConnectionProvider, NetworkConnectionState>(
          selector: (_, connectionProvider) => connectionProvider.wsState,
          builder: (_, state, __) => _state2Text(state),
        ),
        const Text("|"),
        Selector<ConnectionProvider, NetworkConnectionState>(
          selector: (_, connectionProvider) => connectionProvider.dbState,
          builder: (_, state, __) => _state2Text(state),
        ),
        const Text("]"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ConnectionProvider, bool>(
      selector: (_, connectionProvider) => connectionProvider.isConnected,
      builder: (_, isConnected, __) {
        if (isConnected) {
          return const Text("TMS Title", overflow: TextOverflow.ellipsis);
        } else {
          return _stateTitleRow();
        }
      },
    );
  }
}
