import 'dart:async';
import 'dart:ui';

import 'package:app_links/app_links.dart';
import 'package:echo_tree_flutter/logging/logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:tms/app.dart';
import 'package:tms/providers/connection_provider.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/network/network.dart';
import 'package:tms/providers/auth_provider.dart';

class NetworkObserver extends WidgetsBindingObserver {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _appLinkSubscription;

  void handleLink(Uri link) {
    TmsLogger().i('Link: $link');
    if (link.host == 'connect') {
      String? ip = link.queryParameters['ip'];
      String? port = link.queryParameters['port'];

      TmsLogger().i('Received Deep Link to $ip:$port');
      if (!TmsLocalStorageProvider().isReady) {
        TmsLocalStorageProvider().init().then((_) {
          TmsLocalStorageProvider().serverIp = ip ?? '';
          TmsLocalStorageProvider().serverPort = int.tryParse(port ?? '') ?? defaultServerPort;
        });
      } else {
        TmsLocalStorageProvider().serverIp = ip ?? '';
        TmsLocalStorageProvider().serverPort = int.tryParse(port ?? '') ?? defaultServerPort;
      }
    }
  }

  Future<void> initAppLinks() async {
    var link = await _appLinks.getInitialAppLink();
    if (link != null) {
      TmsLogger().i('Initial Link: $link');
      handleLink(link);
    }
    _appLinkSubscription = _appLinks.uriLinkStream.listen(handleLink);
  }

  void disposeAppLinks() {
    _appLinkSubscription?.cancel();
  }

  void networkStartup() async {
    if (!TmsLocalStorageProvider().isReady) {
      TmsLocalStorageProvider().init().then((_) => Network().start());
    } else {
      Network().start();
    }
  }

  @override
  Future<AppExitResponse> didRequestAppExit() {
    disposeAppLinks();
    Network().stop();
    return super.didRequestAppExit();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      disposeAppLinks();
      Network().stop();
    } else if (state == AppLifecycleState.resumed) {
      initAppLinks().then((_) => Network().start());
    }
  }
}

class AppWrapper extends StatelessWidget {
  final Widget child;

  const AppWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TmsLocalStorageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
      ],
      child: child,
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // startup loggers
  Logger().i("TMS App starting...");
  TmsLogger().setLogLevel(LogLevel.info);
  EchoTreeLogger().useLogger(EchoTreeTmsLogBinder());

  // initialize the network observers
  final observer = NetworkObserver();
  WidgetsBinding.instance.addObserver(observer);
  observer.initAppLinks().then((_) {
    observer.networkStartup();
  });

  // set imperative API ans start app
  GoRouter.optionURLReflectsImperativeAPIs = true;
  runApp(const AppWrapper(child: TMSApp()));
}
