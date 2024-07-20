import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:echo_tree_flutter/logging/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:tms/app.dart';
import 'package:tms/generated/frb_generated.dart';
import 'package:tms/network/http_client.dart';
import 'package:tms/providers/connection_provider.dart';
import 'package:tms/providers/event_config_provider.dart';
import 'package:tms/providers/game_timer_provider.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/providers/game_match_provider.dart';
import 'package:tms/providers/schedule_provider.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/network/network.dart';
import 'package:tms/providers/auth_provider.dart';

class NetworkObserver extends WidgetsBindingObserver {
  void networkStartup() async {
    Network().start();
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
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => EventConfigProvider()),
        ChangeNotifierProvider(create: (_) => GameMatchProvider()),
        ChangeNotifierProvider(create: (_) => GameTimerProvider()),
        ChangeNotifierProvider(create: (_) => TeamsProvider()),
      ],
      child: child,
    );
  }
}

void main() async {
  await TmsRustLib.init();
  HttpOverrides.global = TmsHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  // startup loggers
  Logger().i("TMS App starting...");
  TmsLogger().setLogLevel(LogLevel.debug); // info
  EchoTreeLogger().useLogger(EchoTreeTmsLogBinder());

  // initialize local storage (network and some views are dependent on this)
  if (!TmsLocalStorageProvider().isReady) {
    await TmsLocalStorageProvider().init();
  }

  // initialize the network observers (async, don't wait up)
  final observer = NetworkObserver();
  WidgetsBinding.instance.addObserver(observer);
  observer.networkStartup();

  // set imperative API and start app
  GoRouter.optionURLReflectsImperativeAPIs = true;

  runApp(const AppWrapper(child: TMSApp()));
}
