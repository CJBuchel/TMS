import 'package:flutter/material.dart';
import 'package:tms/network/controller/connectivity.dart';
import 'package:tms/network/network.dart';

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

  Widget _vlbText(ValueNotifier<NetworkConnectionState> nt) {
    return ValueListenableBuilder(
      valueListenable: nt,
      builder: (context, state, _) {
        return _state2Text(state);
      },
    );
  }

  Widget _stateTitleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("["),
        _vlbText(Network().innerNetworkStates().$1.notifier), // http
        const Text("|"),
        _vlbText(Network().innerNetworkStates().$2.notifier), // ws
        const Text("|"),
        _vlbText(Network().innerNetworkStates().$3.notifier), // db
        const Text("]"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Network().state,
      builder: (context, state, child) {
        if (state == NetworkConnectionState.connected) {
          return const Text("TMS Title");
        } else {
          return _stateTitleRow();
        }
      },
    );
  }
}
