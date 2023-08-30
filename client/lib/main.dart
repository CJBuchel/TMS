import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tms/app.dart';
import 'package:tms/constants.dart';
import 'package:tms/network/network.dart';

Future<bool> checkConnection() async {
  bool ok = false;
  try {
    ok = await Network.checkConnection();
  } catch (e) {
    rethrow;
  }

  if (!ok) {
    if (await Network.getAutoConfig()) {
      await Network.findServer();
    }

    return false;
  } else {
    return true;
  }
}

bool watchdogFeeding = false;
bool active = true;
void watchDog() async {
  if (!active) return;
  if (!watchdogFeeding) {
    watchdogFeeding = true;
    bool ok = await checkConnection();
    if (!ok && await Network.getAutoConfig()) {
      await Network.findServer();
    }
    watchdogFeeding = false;
  }
}

void networkStartup() async {
  Network.getAutoConfig().then((autoConfig) {
    if (autoConfig) {
      Network.findServer().then((found) {
        // Start watchdog
        watchDog();
        Timer.periodic(watchDogTime, (timer) => watchDog());
      });
    } else {
      // Start watchdog
      watchDog();
      Timer.periodic(watchDogTime, (timer) => watchDog());
    }
  });
}

class NetworkObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      active = false;
      Network.disconnect();
    } else if (state == AppLifecycleState.resumed) {
      active = true;
      watchDog();
    }
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final networkObserver = NetworkObserver();
  WidgetsBinding.instance.addObserver(networkObserver);
  networkStartup();
  runApp(const TMSApp());
}
