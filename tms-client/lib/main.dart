import 'dart:ui';

import 'package:echo_tree_flutter/logging/logger.dart';
import 'package:flutter/material.dart';

import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:tms/app.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/network/network.dart';
import 'package:tms/providers/auth_provider.dart';

class NetworkObserver extends WidgetsBindingObserver {
  void networkStartup() {
    if (!TmsLocalStorageProvider().isReady) {
      TmsLocalStorageProvider().init().then((_) => Network().start());
    } else {
      Network().start();
    }
  }

  @override
  Future<AppExitResponse> didRequestAppExit() {
    Network().stop();
    return super.didRequestAppExit();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      Network().stop();
    } else if (state == AppLifecycleState.resumed) {
      Network().start();
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
      ],
      child: child,
    );
  }
}

void main() {
  Logger().i("TMS App starting...");
  TmsLogger().setLogLevel(LogLevel.info);
  EchoTreeLogger().useLogger(EchoTreeTmsLogBinder());
  WidgetsFlutterBinding.ensureInitialized();
  final observer = NetworkObserver();
  WidgetsBinding.instance.addObserver(observer);
  observer.networkStartup();
  runApp(AppWrapper(child: TMSApp()));
}
