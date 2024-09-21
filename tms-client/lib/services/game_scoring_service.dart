import 'dart:io';

import 'package:tms/generated/infra/database_schemas/game_score_sheet.dart';
import 'package:tms/generated/infra/network_schemas/robot_game_requests.dart';
import 'package:tms/network/network.dart';
import 'package:tms/utils/logger.dart';

class GameScoringService {
  Future<int> sendTableNotReadySignal(String table, String teamNumber) async {
    try {
      var request = RobotGamesTableSignalRequest(table: table, teamNumber: teamNumber).toJsonString();
      var response = await Network().networkPost("/robot_game/tables/not_ready_signal", request);
      if (response.$1) {
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> sendTableReadySignal(String table, String? teamNumber) async {
    try {
      var request = RobotGamesTableSignalRequest(table: table, teamNumber: teamNumber ?? "").toJsonString();
      var response = await Network().networkPost("/robot_game/tables/ready_signal", request);
      if (response.$1) {
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> submitScoreSheet(RobotGamesScoreSheetRequest scoreSheet) async {
    try {
      var request = scoreSheet.toJsonString();
      var response = await Network().networkPost("/robot_game/scoring/submit_score_sheet", request);
      if (response.$1) {
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> updateScoreSheet(String scoreSheetId, GameScoreSheet scoreSheet) async {
    try {
      var request = RobotGamesUpdateScoreSheetRequest(
        scoreSheetId: scoreSheetId,
        scoreSheet: scoreSheet,
      ).toJsonString();
      var response = await Network().networkPost("/robot_game/scoring/update_score_sheet", request);
      if (response.$1) {
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> removeScoreSheet(String scoreSheetId) async {
    try {
      var request = RobotGamesRemoveScoreSheetRequest(scoreSheetId: scoreSheetId).toJsonString();
      var response = await Network().networkDelete("/robot_game/scoring/remove_score_sheet", request);
      if (response.$1) {
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
