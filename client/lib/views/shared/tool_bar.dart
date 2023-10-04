import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/network/auth.dart';

import 'package:tms/network/http.dart';
import 'package:tms/network/network.dart';
import 'package:tms/network/security.dart';
import 'package:tms/network/ws.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';

class TmsToolBar extends StatefulWidget implements PreferredSizeWidget {
  final bool displayActions;
  final bool displayMenuButton;
  final VoidCallback? onBackButtonPressed;
  final VoidCallback? onMenuButtonPressed;

  const TmsToolBar({
    super.key,
    this.displayActions = true,
    this.displayMenuButton = false,
    this.onBackButtonPressed,
    this.onMenuButtonPressed,
  });

  @override
  State<TmsToolBar> createState() => _TmsToolBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TmsToolBarState extends State<TmsToolBar> with SingleTickerProviderStateMixin, AutoUnsubScribeMixin, LocalDatabaseMixin {
  Icon connectionIcon = const Icon(Icons.signal_wifi_connected_no_internet_4_outlined, color: Colors.red);
  Icon themeIcon = const Icon(Icons.light_mode, color: Colors.white);
  Icon loginIcon = const Icon(Icons.login_sharp, color: Colors.red);

  double _scaledFontSize = 20;

  late AnimationController _animationController;

  Text ntStatusText = const Text(
    "NO NT",
    style: TextStyle(color: Colors.red, fontSize: 20),
    overflow: TextOverflow.ellipsis,
  );

  Text wsStatusText = const Text(
    "NO WS",
    style: TextStyle(color: Colors.red, fontSize: 20),
    overflow: TextOverflow.ellipsis,
  );

  Text secStateText = const Text(
    "NO SEC",
    style: TextStyle(color: Colors.red, fontSize: 20),
    overflow: TextOverflow.ellipsis,
  );

  List<Widget> titleBar = const [];
  String loginScreen = "/login";

  // check the nt status
  Future<void> checkHTTP(NetworkHttpConnectionState state) async {
    switch (state) {
      case NetworkHttpConnectionState.disconnected:
        setState(() {
          ntStatusText = Text(
            "NO NT",
            style: TextStyle(color: Colors.red, fontSize: _scaledFontSize),
            overflow: TextOverflow.ellipsis,
          );
        });
        break;

      case NetworkHttpConnectionState.connectedNoPulse:
        setState(() {
          ntStatusText = Text(
            "NO PULSE",
            style: TextStyle(color: Colors.orange, fontSize: _scaledFontSize),
            overflow: TextOverflow.ellipsis,
          );
        });
        break;

      case NetworkHttpConnectionState.connected:
        setState(() {
          ntStatusText = Text(
            "OK",
            style: TextStyle(color: Colors.green, fontSize: _scaledFontSize),
            overflow: TextOverflow.ellipsis,
          );
        });
        break;
      default:
        setState(() {
          ntStatusText = Text(
            "NO NT",
            style: TextStyle(color: Colors.red, fontSize: _scaledFontSize),
            overflow: TextOverflow.ellipsis,
          );
        });
    }
  }

  Future<void> checkWS(NetworkWebSocketState state) async {
    switch (state) {
      case NetworkWebSocketState.disconnected:
        setState(() {
          wsStatusText = Text(
            "NO WS",
            style: TextStyle(color: Colors.red, fontSize: _scaledFontSize),
            overflow: TextOverflow.ellipsis,
          );
        });
        break;

      case NetworkWebSocketState.connected:
        setState(() {
          wsStatusText = Text(
            "OK",
            style: TextStyle(color: Colors.green, fontSize: _scaledFontSize),
            overflow: TextOverflow.ellipsis,
          );
        });
        break;
      default:
        setState(() {
          wsStatusText = Text(
            "NO WS",
            style: TextStyle(color: Colors.red, fontSize: _scaledFontSize),
            overflow: TextOverflow.ellipsis,
          );
        });
    }
  }

  Future<void> checkSec(SecurityState state) async {
    switch (state) {
      case SecurityState.noSecurity:
        setState(() {
          secStateText = Text(
            "NO SEC",
            style: TextStyle(color: Colors.red, fontSize: _scaledFontSize),
            overflow: TextOverflow.ellipsis,
          );
        });
        break;
      case SecurityState.encrypting:
        setState(() {
          secStateText = Text(
            "ENC",
            style: TextStyle(color: Colors.orange, fontSize: _scaledFontSize),
            overflow: TextOverflow.ellipsis,
          );
        });
        break;
      case SecurityState.secure:
        setState(() {
          secStateText = Text(
            "SECURE",
            style: TextStyle(color: Colors.green, fontSize: _scaledFontSize),
            overflow: TextOverflow.ellipsis,
          );
        });
        break;
      default:
        setState(() {
          secStateText = Text(
            "NO SEC",
            style: TextStyle(color: Colors.red, fontSize: _scaledFontSize),
            overflow: TextOverflow.ellipsis,
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
        getEvent().then((event) => getTitle(event));
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
        loginIcon = const Icon(Icons.person, color: Colors.white);
        loginScreen = "/logout";
      });
    } else {
      setState(() {
        loginIcon = const Icon(Icons.login_sharp, color: Colors.red);
        loginScreen = "/login";
      });
    }
  }

  void checkTheme() {
    if (AppTheme.isDarkTheme) {
      setState(() {
        themeIcon = const Icon(Icons.light_mode, color: Colors.white);
      });
    } else {
      setState(() {
        themeIcon = const Icon(Icons.brightness_3_sharp, color: Colors.white);
      });
    }
  }

  void getTitle(Event event) {
    setState(() {
      titleBar = [Text(event.name, overflow: TextOverflow.ellipsis)];
    });
  }

  @override
  void initState() {
    super.initState();

    onEventUpdate((event) {
      getTitle(event);
    });

    checkConnection();
    checkLogin();
    checkTheme();

    // animation controller
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat();

    AppTheme.isDarkThemeNotifier.addListener(checkTheme);

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

    AppTheme.isDarkThemeNotifier.removeListener(checkTheme);

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
    if (!Responsive.isMobile(context)) {
      if (widget.displayActions) {
        return [
          IconButton(
            onPressed: () => AppTheme.setDarkTheme = !AppTheme.isDarkTheme,
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
            onPressed: () => AppTheme.setDarkTheme = !AppTheme.isDarkTheme,
            icon: themeIcon,
          ),
        ];
      }
    } else {
      if (widget.displayActions) {
        return [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: Colors.blueGrey[800],
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: themeIcon,
                  title: const Text("Theme", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    AppTheme.setDarkTheme = !AppTheme.isDarkTheme;
                    Navigator.pop(context);
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: connectionIcon,
                  title: const Text("Server Connection", style: TextStyle(color: Colors.white)),
                  onTap: () => pushTo(context, "/server_connection"),
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: loginIcon,
                  title: const Text("Login/Logout", style: TextStyle(color: Colors.white)),
                  onTap: () => pushTo(context, loginScreen),
                ),
              ),
            ],
          ),
        ];
      } else {
        return [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: Colors.blueGrey[800],
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: themeIcon,
                  title: const Text("Theme", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    AppTheme.setDarkTheme = !AppTheme.isDarkTheme;
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ];
      }
    }
  }

  Widget leading() {
    if (Navigator.canPop(context)) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: widget.onBackButtonPressed ?? () => Navigator.pop(context),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      _scaledFontSize = 25;
    }

    if (Responsive.isTablet(context)) {
      _scaledFontSize = 20;
    }

    if (Responsive.isMobile(context)) {
      _scaledFontSize = 15;
    }

    return AppBar(
      backgroundColor: Colors.blueGrey[800],
      titleTextStyle: TextStyle(fontSize: _scaledFontSize, color: Colors.white, fontFamily: defaultFontFamilyBold),
      iconTheme: IconThemeData(size: _scaledFontSize, color: Colors.white),

      // back button if applicable
      leading: leading(),

      // title
      title: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              if (widget.displayMenuButton)
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: widget.onMenuButtonPressed ?? () => Scaffold.of(context).openDrawer(),
                ),

              // This will take any remaining space and push the next widgets to the end
              const Expanded(child: SizedBox.shrink()),

              // Use a container to set a fixed width to the middle content
              SizedBox(
                width: constraints.maxWidth * 0.5, // Taking up to half the available space
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: titleBar,
                ),
              ),

              // This will take any remaining space after the middle content
              const Expanded(child: SizedBox.shrink()),
            ],
          );
        },
      ),

      // right actions
      actions: getActions(),
    );
  }
}
