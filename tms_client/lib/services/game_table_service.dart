import 'dart:io';

import 'package:tms/generated/infra/network_schemas/robot_game_table_requests.dart';
import 'package:tms/network/network.dart';
import 'package:tms/utils/logger.dart';

class GameTableService {
  Future<int> insertTable(String? tableId, String table) async {
    try {
      var request = RobotGameTableInsertRequest(tableId: tableId, table: table).toJsonString();
      var response = await Network().networkPost("/robot_game/tables/insert_table", request);
      if (response.$1) {
        TmsLogger().i("Inserted table: $table");
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> removeTable(String tableId) async {
    try {
      var request = RobotGameTableRemoveRequest(tableId: tableId).toJsonString();
      var response = await Network().networkDelete("/robot_game/tables/remove_table", request);
      if (response.$1) {
        TmsLogger().i("Removed table: $tableId");
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
