import 'package:flutter/material.dart';
import 'package:tms/network/http.dart';
import 'package:tms/network/security.dart';
import 'package:tms/network/ws.dart';
import 'package:tms/utils/value_listenable_utils.dart';
import 'package:tms/views/shared/toolbar/event_title.dart';

class TmsToolBarTitleBar extends StatelessWidget {
  final double fontSize;
  TmsToolBarTitleBar({
    Key? key,
    this.fontSize = 20,
  }) : super(key: key);

  final ValueNotifier<bool> _networkState = ValueNotifier(false);

  void checkNetwork() async {
    bool connected = true;

    if (NetworkHttp().httpState.value != NetworkHttpConnectionState.connected) {
      connected = false;
    }

    if (NetworkWebSocket().wsState.value != NetworkWebSocketState.connected) {
      connected = false;
    }

    if (NetworkSecurity().securityState.value != SecurityState.secure) {
      connected = false;
    }

    if (_networkState.value != connected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _networkState.value = connected;
      });
    }
  }

  Widget httpStatus() {
    return ValueListenableBuilder(
      valueListenable: NetworkHttp().httpState,
      builder: (context, state, _) {
        checkNetwork();
        switch (state) {
          case NetworkHttpConnectionState.disconnected:
            return Text(
              'NO NT',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              overflow: TextOverflow.ellipsis,
            );

          case NetworkHttpConnectionState.connectedNoPulse:
            return Text(
              'NO PULSE',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
              overflow: TextOverflow.ellipsis,
            );

          case NetworkHttpConnectionState.connected:
            return Text(
              'OK',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              overflow: TextOverflow.ellipsis,
            );

          default:
            return const Text('-');
        }
      },
    );
  }

  Widget wsStatus() {
    return ValueListenableBuilder(
      valueListenable: NetworkWebSocket().wsState,
      builder: (context, state, _) {
        checkNetwork();
        switch (state) {
          case NetworkWebSocketState.disconnected:
            return Text(
              'NO WS',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              overflow: TextOverflow.ellipsis,
            );

          case NetworkWebSocketState.connected:
            return Text(
              'OK',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              overflow: TextOverflow.ellipsis,
            );

          default:
            return const Text('-');
        }
      },
    );
  }

  Widget secState() {
    return ValueListenableBuilder(
      valueListenable: NetworkSecurity().securityState,
      builder: (context, state, _) {
        checkNetwork();
        switch (state) {
          case SecurityState.noSecurity:
            return Text(
              'NO SEC',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              overflow: TextOverflow.ellipsis,
            );

          case SecurityState.encrypting:
            return Text(
              'ENC',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
              overflow: TextOverflow.ellipsis,
            );

          case SecurityState.secure:
            return Text(
              'OK',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              overflow: TextOverflow.ellipsis,
            );
          default:
            return const Text('-');
        }
      },
    );
  }

  Widget networkTitle() {
    return Row(
      children: [
        const Text("["),
        secState(), // stage 1
        const Text("/"),
        httpStatus(), // stage 2
        const Text("/"),
        wsStatus(), // stage 3
        const Text("]"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _networkState,
      builder: (context, connected, child) {
        if (connected) {
          // make another listener dedicated for if the network changes after the initial connection
          return ValueListenableBuilder3(
            first: NetworkHttp().httpState,
            second: NetworkWebSocket().wsState,
            third: NetworkSecurity().securityState,
            builder: (context, http, ws, sec, _) {
              checkNetwork();
              return const TmsToolBarEventTitle();
            },
          );
        } else {
          return networkTitle();
        }
      },
    );
  }
}
