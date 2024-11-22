import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/network/connectivity.dart';
import 'package:tms/providers/connection_provider.dart';
import 'package:tms/providers/tournament_config_provider.dart';

class TmsAppBarTitle extends StatelessWidget {
  TmsAppBarTitle({super.key});

  Text _state2Text(NetworkConnectionState state) {
    switch (state) {
      case NetworkConnectionState.disconnected:
        return const Text("DC", style: TextStyle(color: Colors.red));
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

  Widget _eventTitle() {
    return Selector<TournamentConfigProvider, String>(
      selector: (_, configProvider) => configProvider.eventName,
      builder: (_, eventName, __) {
        return Text(eventName, overflow: TextOverflow.ellipsis);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ConnectionProvider, bool>(
      selector: (_, connectionProvider) => connectionProvider.isConnected,
      builder: (_, isConnected, __) {
        if (isConnected) {
          return EchoTreeLifetime(trees: [":tournament:config"], child: _eventTitle());
        } else {
          return _stateTitleRow();
        }
      },
    );
  }
}
