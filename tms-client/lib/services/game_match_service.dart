import 'dart:io';

import 'package:tms/network/network.dart';
import 'package:tms/schemas/network_schema.dart';
import 'package:tms/utils/logger.dart';

class GameMatchService {
  Future<int> loadMatches(List<String> gameMatchNumbers) async {
    try {
      var request = RobotGamesLoadMatchRequest(gameMatchNumbers: gameMatchNumbers).toJson();
      var response = await Network().networkPost("/robot_game/matches", request);
      if (response.$1) {
        TmsLogger().i("Loaded game matches: $gameMatchNumbers");
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
