import 'dart:io';

import 'package:logger/logger.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tuple/tuple.dart';

Future<Tuple2<int, List<Team>>> getTeamsRequest() async {
  try {
    var res = await Network.serverGet("teams/get");

    if (res.item1 && res.item3.isNotEmpty) {
      return Tuple2(res.item2, TeamsResponse.fromJson(res.item3).teams);
    } else {
      return Tuple2(res.item2, []);
    }
  } catch (e) {
    Logger().e(e);
    return const Tuple2(HttpStatus.badRequest, []);
  }
}

Future<Tuple2<int, Team?>> getTeamRequest(String teamNumber) async {
  try {
    var message = TeamRequest(teamNumber: teamNumber).toJson();
    var res = await Network.serverPost("team/get", message);

    if (res.item1 && res.item3.isNotEmpty) {
      Team team = TeamResponse.fromJson(res.item3).team;
      return Tuple2(res.item2, team);
    } else {
      return Tuple2(res.item2, null);
    }
  } catch (e) {
    Logger().e(e);
    return const Tuple2(HttpStatus.badRequest, null);
  }
}

Future<int> updateTeamRequest(String originTeamNumber, Team team) async {
  try {
    var message = TeamUpdateRequest(authToken: await NetworkAuth.getToken(), teamNumber: originTeamNumber, teamData: team);
    var res = await Network.serverPost("team/update", message.toJson());
    if (res.item1) {
      return res.item2;
    } else {
      return res.item2;
    }
  } catch (e) {
    Logger().e(e);
    return HttpStatus.badRequest;
  }
}

Future<int> deleteTeamRequest(String teamNumber) async {
  try {
    var message = TeamDeleteRequest(authToken: await NetworkAuth.getToken(), teamNumber: teamNumber);
    var res = await Network.serverPost("team/delete", message.toJson());
    if (res.item1) {
      return res.item2;
    } else {
      return res.item2;
    }
  } catch (e) {
    Logger().e(e);
    return HttpStatus.badRequest;
  }
}

Future<int> addTeamRequest(String number, String name, String aff) async {
  try {
    var message = TeamAddRequest(authToken: await NetworkAuth.getToken(), teamNumber: number, teamName: name, teamAffiliation: aff);
    var res = await Network.serverPost("team/add", message.toJson());
    if (res.item1) {
      return res.item2;
    } else {
      return res.item2;
    }
  } catch (e) {
    Logger().e(e);
    return HttpStatus.badRequest;
  }
}

Future<int> postTeamGameScoresheetRequest(
  String teamNumber,
  TeamGameScore scoresheet, {
  bool updateMatch = false,
  String? matchNumber,
  String? table,
}) async {
  try {
    var scoresheetRequest = TeamPostGameScoresheetRequest(
      authToken: await NetworkAuth.getToken(),
      teamNumber: teamNumber,
      scoresheet: scoresheet,
      updateMatch: updateMatch,
      matchNumber: matchNumber,
      table: table,
    );
    var res = await Network.serverPost("team/post/game_scoresheet", scoresheetRequest.toJson());
    if (res.item1) {
      return res.item2;
    } else {
      return res.item2;
    }
  } catch (e) {
    Logger().e(e);
    return HttpStatus.badRequest;
  }
}
