import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tms/network/connectivity.dart';
import 'package:tms/providers/connection_provider.dart';

class TmsAppBarSettingsAction extends StatelessWidget {
  final GoRouterState state;

  const TmsAppBarSettingsAction({
    Key? key,
    required this.state,
  }) : super(key: key);

  Icon _state2Wifi(NetworkConnectionState state) {
    IconData icon = Icons.settings;
    Color color = Colors.white;

    switch (state) {
      case NetworkConnectionState.disconnected:
        color = Colors.red;
      case NetworkConnectionState.connecting:
        color = Colors.orange;
      case NetworkConnectionState.connected:
        color = Colors.white;
    }

    return Icon(icon, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ConnectionProvider, NetworkConnectionState>(
      selector: (_, connectionProvider) => connectionProvider.state,
      builder: (_, connectionSate, __) => IconButton(
        onPressed: () {
          if (state.matchedLocation == '/connection') {
            context.go('/');
          } else {
            context.goNamed('connection');
          }
        },
        icon: _state2Wifi(connectionSate),
      ),
    );
  }
}
