import 'dart:io';

import 'package:tms/generated/infra/database_schemas/game_score_sheet.dart';
import 'package:tms/generated/infra/network_schemas/robot_game_score_sheet_requests.dart';
import 'package:tms/generated/infra/network_schemas/robot_game_table_requests.dart';
import 'package:tms/network/network.dart';
import 'package:tms/utils/logger.dart';

class GameScoringService {
  Future<int> sendTableNotReadySignal(String table, String teamNumber) async {
    try {
      var request = RobotGameTableSignalRequest(table: table, teamNumber: teamNumber).toJsonString();
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
      var request = RobotGameTableSignalRequest(table: table, teamNumber: teamNumber ?? "").toJsonString();
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

  Future<int> submitScoreSheet(RobotGameScoreSheetSubmitRequest scoreSheet) async {
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

  Future<int> insertScoreSheet(String? scoreSheetId, GameScoreSheet scoreSheet) async {
    try {
      var request = RobotGameScoreSheetInsertRequest(
        scoreSheetId: scoreSheetId,
        scoreSheet: scoreSheet,
      ).toJsonString();
      var response = await Network().networkPost("/robot_game/scoring/insert_score_sheet", request);
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
      var request = RobotGameScoreSheetRemoveRequest(scoreSheetId: scoreSheetId).toJsonString();
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
