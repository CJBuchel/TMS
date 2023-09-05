import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/network/auth.dart';

import 'package:tms/network/http.dart';
import 'package:tms/network/network.dart';
import 'package:tms/network/security.dart';
import 'package:tms/network/ws.dart';
import 'package:tms/responsive.dart';

class TmsToolBar extends StatefulWidget with PreferredSizeWidget {
  TmsToolBar({super.key, this.displayActions = true});

  final bool displayActions;

  @override
  TmsToolBarState createState() => TmsToolBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class TmsToolBarState extends State<TmsToolBar> with SingleTickerProviderStateMixin {
  Icon connectionIcon = const Icon(Icons.signal_wifi_connected_no_internet_4_outlined, color: Colors.red);
  Icon themeIcon = const Icon(Icons.light_mode, color: Colors.white);
  Icon loginIcon = const Icon(Icons.login_sharp, color: Colors.red);

  late AnimationController _animationController;

  Text ntStatusText = const Text(
    "NO NT",
    style: TextStyle(color: Colors.red),
  );

  Text wsStatusText = const Text(
    "NO WS",
    style: TextStyle(color: Colors.red),
  );

  Text secStateText = const Text(
    "NO SEC",
    style: TextStyle(color: Colors.red),
  );

  List<Widget> titleBar = const [];
  String loginScreen = "/login";

  // check the nt status
  Future<void> checkHTTP(NetworkHttpConnectionState state) async {
    switch (state) {
      case NetworkHttpConnectionState.disconnected:
        setState(() {
          ntStatusText = const Text(
            "NO NT",
            style: TextStyle(color: Colors.red),
          );
        });
        break;

      case NetworkHttpConnectionState.connectedNoPulse:
        setState(() {
          ntStatusText = const Text(
            "NO PULSE",
            style: TextStyle(color: Colors.orange),
          );
        });
        break;

      case NetworkHttpConnectionState.connected:
        setState(() {
          ntStatusText = const Text(
            "OK",
            style: TextStyle(color: Colors.green),
          );
        });
        break;
      default:
        setState(() {
          ntStatusText = const Text(
            "NO NT",
            style: TextStyle(color: Colors.red),
          );
        });
    }
  }

  Future<void> checkWS(NetworkWebSocketState state) async {
    switch (state) {
      case NetworkWebSocketState.disconnected:
        setState(() {
          wsStatusText = const Text(
            "NO WS",
            style: TextStyle(color: Colors.red),
          );
        });
        break;

      case NetworkWebSocketState.connected:
        setState(() {
          wsStatusText = const Text(
            "OK",
            style: TextStyle(color: Colors.green),
          );
        });
        break;
      default:
        setState(() {
          wsStatusText = const Text(
            "NO WS",
            style: TextStyle(color: Colors.red),
          );
        });
    }
  }

  Future<void> checkSec(SecurityState state) async {
    switch (state) {
      case SecurityState.noSecurity:
        setState(() {
          secStateText = const Text(
            "NO SEC",
            style: TextStyle(color: Colors.red),
          );
        });
        break;
      case SecurityState.encrypting:
        setState(() {
          secStateText = const Text(
            "ENC",
            style: TextStyle(color: Colors.orange),
          );
        });
        break;
      case SecurityState.secure:
        setState(() {
          secStateText = const Text(
            "SECURE",
            style: TextStyle(color: Colors.green),
          );
        });
        break;
      default:
        setState(() {
          secStateText = const Text(
            "NO SEC",
            style: TextStyle(color: Colors.red),
          );
        });
    }
  }

  // Quickly check the network connection and provide a color code to the network icon
  Future<void> checkNetwork(NetworkHttpConnectionState httpState, NetworkWebSocketState wsState, SecurityState secState) async {
    var row = [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [const Text("["), ntStatusText, const Text("/"), secStateText, const Text("/"), wsStatusText, const Text("]")],
      )
    ];

    if (httpState == NetworkHttpConnectionState.connected && wsState == NetworkWebSocketState.connected && secState == SecurityState.secure) {
      setState(() {
        connectionIcon = const Icon(Icons.wifi, color: Colors.green);
        titleBar = [
          const Text(
            "THIS IS A LONG TITLE",
          )
        ];
      });
    } else if (httpState == NetworkHttpConnectionState.disconnected &&
        wsState == NetworkWebSocketState.disconnected &&
        secState == SecurityState.noSecurity) {
      setState(() {
        connectionIcon = const Icon(Icons.signal_wifi_connected_no_internet_4_outlined, color: Colors.red);
        titleBar = row;
      });
    } else {
      setState(() {
        connectionIcon = const Icon(Icons.signal_wifi_statusbar_connected_no_internet_4_outlined, color: Colors.orange);
        titleBar = row;
      });
    }
  }

  void checkConnection() async {
    var states = await Network.getStates();
    await checkHTTP(states.item1);
    await checkWS(states.item2);
    await checkSec(states.item3);
    await checkNetwork(states.item1, states.item2, states.item3);
  }

  void checkLogin() async {
    bool loginState = await NetworkAuth.getLoginState();
    if (loginState) {
      setState(() {
        loginIcon = const Icon(Icons.person);
        loginScreen = "/logout";
      });
    } else {
      setState(() {
        loginIcon = const Icon(Icons.login_sharp, color: Colors.red);
        loginScreen = "/login";
      });
    }
  }

  void toggleTheme() {
    if (isDarkTheme.value) {
      setState(() {
        themeIcon = const Icon(Icons.light_mode, color: Colors.white);
      });
    } else {
      setState(() {
        themeIcon = const Icon(Icons.brightness_3_sharp, color: Colors.white);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkConnection();
    checkLogin();

    // animation controller
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat();

    isDarkTheme.addListener(toggleTheme);

    NetworkHttp.httpState.addListener(checkConnection);
    NetworkWebSocket.wsState.addListener(checkConnection);
    NetworkSecurity.securityState.addListener(checkConnection);
    NetworkAuth.loginState.addListener(checkLogin);
  }

  @override
  void didUpdateWidget(TmsToolBar oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();

    isDarkTheme.removeListener(toggleTheme);

    NetworkHttp.httpState.removeListener(checkConnection);
    NetworkWebSocket.wsState.removeListener(checkConnection);
    NetworkSecurity.securityState.removeListener(checkConnection);
    NetworkAuth.loginState.removeListener(checkLogin);
  }

  void pushTo(BuildContext context, String named) {
    if (ModalRoute.of(context)?.settings.name != named) {
      Navigator.pushNamed(context, named);
    } else {
      Navigator.pop(context);
    }
  }

  List<Widget> getActions() {
    if (widget.displayActions) {
      return [
        IconButton(
          onPressed: () => isDarkTheme.value = !isDarkTheme.value,
          icon: themeIcon,
        ),
        IconButton(
          onPressed: () => pushTo(context, "/server_connection"),
          icon: connectionIcon,
        ),
        IconButton(
          onPressed: () => pushTo(context, loginScreen),
          icon: loginIcon,
        ),
      ];
    } else {
      return [
        IconButton(
          onPressed: () => isDarkTheme.value = !isDarkTheme.value,
          icon: themeIcon,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = 25;
    if (Responsive.isTablet(context)) {
      fontSize = 24;
    } else if (Responsive.isMobile(context)) {
      fontSize = 18;
    }

    return AppBar(
      titleTextStyle: TextStyle(fontSize: fontSize, color: Colors.white, fontFamily: defaultFontFamilyBold),
      iconTheme: IconThemeData(size: fontSize),
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: titleBar),
      actions: getActions(),
    );
  }
}
