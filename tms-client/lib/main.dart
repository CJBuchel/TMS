import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:logger/web.dart';
import 'package:tms/app.dart';
import 'package:tms/constants.dart';
import 'package:tms/logger.dart';
import 'package:tms/network/network.dart';

class NetworkObserver extends WidgetsBindingObserver {
  void networkStartup() {
    if (!TmsLocalStorage().isReady) {
      TmsLocalStorage().init().then((_) => Network().start());
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

void main() async {
  Logger().i("TMS App starting...");
  TmsLogger().setLogLevel(LogLevel.info); // set log level to info
  WidgetsFlutterBinding.ensureInitialized();
  final observer = NetworkObserver();
  WidgetsBinding.instance.addObserver(observer);
  observer.networkStartup();
  runApp(const TMSApp());
}
