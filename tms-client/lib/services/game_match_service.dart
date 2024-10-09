import 'dart:io';

import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/network_schemas/robot_game_match_requests.dart';
import 'package:tms/network/network.dart';
import 'package:tms/utils/logger.dart';

class GameMatchService {
  Future<int> loadMatches(List<String> gameMatchNumbers) async {
    try {
      var request = RobotGameMatchLoadRequest(gameMatchNumbers: gameMatchNumbers).toJsonString();
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
      var response = await Network().networkPost("/robot_game/matches/unload_matches", null);
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

  Future<int> readyMatches() async {
    try {
      var response = await Network().networkPost("/robot_game/matches/ready_matches", null);
      if (response.$1) {
        TmsLogger().i("Ready game matches");
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> unreadyMatches() async {
    try {
      var response = await Network().networkPost("/robot_game/matches/unready_matches", null);
      if (response.$1) {
        TmsLogger().i("Unready game matches");
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> insertMatch(String? matchId, GameMatch match) async {
    try {
      var request = RobotGameMatchInsertRequest(matchId: matchId, gameMatch: match).toJsonString();
      var response = await Network().networkPost("/robot_game/matches/insert_match", request);
      if (response.$1) {
        TmsLogger().d("Updated game match: $matchId");
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> removeMatch(String matchId) async {
    try {
      var request = RobotGameMatchRemoveRequest(matchId: matchId).toJsonString();
      var response = await Network().networkDelete("/robot_game/matches/remove_match", request);
      if (response.$1) {
        TmsLogger().d("Removed game match: $matchId");
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
