import 'dart:io';

import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/generated/infra/network_schemas/team_requests.dart';
import 'package:tms/network/network.dart';
import 'package:tms/utils/logger.dart';

class TeamService {
  Future<int> insertTeam(String? teamId, Team team) async {
    try {
      var request = TeamInsertRequest(teamId: teamId, team: team);
      var response = await Network().networkPost("/teams/update_team", request.toJsonString());
      if (response.$1) {
        TmsLogger().d("Updated team: $teamId");
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> removeTeam(String teamId) async {
    try {
      var request = TeamRemoveRequest(teamId: teamId);
      var response = await Network().networkPost("/teams/remove_team", request.toJsonString());
      if (response.$1) {
        TmsLogger().d("Deleted team: $teamId");
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
