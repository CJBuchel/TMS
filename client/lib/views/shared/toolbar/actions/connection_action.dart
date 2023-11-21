import 'package:flutter/material.dart';
import 'package:tms/network/http.dart';
import 'package:tms/network/ws.dart';
import 'package:tms/utils/navigator_wrappers.dart';
import 'package:tms/utils/value_listenable_utils.dart';

class TmsToolBarConnectionAction extends StatelessWidget {
  final bool? listTile;
  const TmsToolBarConnectionAction({
    Key? key,
    this.listTile,
  }) : super(key: key);

  Widget getIcon(NetworkHttpConnectionState a, NetworkWebSocketState b) {
    if (a == NetworkHttpConnectionState.connected && b == NetworkWebSocketState.connected) {
      return const Icon(
        Icons.wifi,
        color: Colors.green,
      );
    } else if (a != NetworkHttpConnectionState.connected && b != NetworkWebSocketState.connected) {
      return const Icon(
        Icons.signal_wifi_connected_no_internet_4_sharp,
        color: Colors.red,
      );
    } else {
      return const Icon(
        Icons.signal_wifi_statusbar_connected_no_internet_4_sharp,
        color: Colors.orange,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder2(
      first: NetworkHttp.httpState,
      second: NetworkWebSocket.wsState,
      builder: ((_, a, b, __) {
        if (listTile ?? false) {
          return ListTile(
            leading: getIcon(a, b),
            title: const Text("Connection"),
            onTap: () {
              Navigator.pop(context);
              pushTo(context, "/server_connection");
            },
          );
        } else {
          return IconButton(
            icon: getIcon(a, b),
            onPressed: () => pushTo(context, "/server_connection"),
          );
        }
      }),
    );
  }
}
