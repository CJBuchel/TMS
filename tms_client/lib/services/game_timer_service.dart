import 'dart:io';

import 'package:tms/network/network.dart';
import 'package:tms/utils/logger.dart';

class GameTimerService {
  Future<int> startTimer() async {
    try {
      var response = await Network().networkPost("/robot_game/timer/start", null);
      if (response.$1) {
        TmsLogger().i("Started timer");
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> startTimerWithCountdown() async {
    try {
      var response = await Network().networkPost("/robot_game/timer/start_countdown", null);
      if (response.$1) {
        TmsLogger().i("Started timer with countdown");
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> stopTimer() async {
    try {
      var response = await Network().networkPost("/robot_game/timer/stop", null);
      if (response.$1) {
        TmsLogger().i("Stopped timer");
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }
}
