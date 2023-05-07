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
void watchDog() async {
  if (!watchdogFeeding) {
    watchdogFeeding = true;
    checkConnection();
    watchdogFeeding = false;
  }
}

void networkStartup() async {
  Network.reset().then((v) {
    Network.getAutoConfig().then((autoConfig) {
      if (autoConfig) {
        Network.findServer().then((found) {
          if (found) {
            try {
              Network.connect();
            } catch (e) {
              rethrow;
            }
          }
        }).then((v) {
          // Start watchdog
          Timer.periodic(watchDogTime, (timer) => watchDog());
        });
      } else {
        Network.getServerIP().then((ip) {
          if (ip.isNotEmpty) {
            try {
              Network.connect();
            } catch (e) {
              rethrow;
            }
          }
        }).then((v) {
          // Start watchdog
          Timer.periodic(watchDogTime, (timer) => watchDog());
        });
      }
    });
  });
}

Future<void> stopNetwork() async {
  await Network.disconnect();
}

void main() async {
  networkStartup();
  runApp(const TMSApp());
  await stopNetwork();
}
