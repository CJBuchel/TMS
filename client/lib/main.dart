import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

void main() async {
  await dotenv.load(fileName: ".env");

  // clear local storage if debug mode
  if (kDebugMode && !kIsWeb) {
    SharedPreferences.getInstance().then((value) => value.clear()); // clear everything if in debug mode
  }

  WidgetsFlutterBinding.ensureInitialized();
  final networkObserver = NetworkObserver();
  WidgetsBinding.instance.addObserver(networkObserver);
  networkStartup(); // startup network
  runApp(const TMSApp());
}
