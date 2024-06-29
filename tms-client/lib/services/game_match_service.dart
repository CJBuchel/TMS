import 'dart:io';

import 'package:tms/generated/infra/network_schemas/robot_game_requests.dart';
import 'package:tms/network/network.dart';
import 'package:tms/utils/logger.dart';

class GameMatchService {
  Future<int> loadMatches(List<String> gameMatchNumbers) async {
    try {
      var request = RobotGamesLoadMatchRequest(gameMatchNumbers: gameMatchNumbers).toJsonString();
      var response = await Network().networkPost("/robot_game/matches/load_matches", request);
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

  Future<int> unloadMatches() async {
    try {
      var response = await Network().networkPost("/robot_game/matches/unload_matches", {});
      if (response.$1) {
        TmsLogger().i("Unloaded game matches");
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
