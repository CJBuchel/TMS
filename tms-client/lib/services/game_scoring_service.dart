import 'dart:io';

import 'package:tms/generated/infra/network_schemas/robot_game_requests.dart';
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
}
