import 'dart:io';

import 'package:logger/logger.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tuple/tuple.dart';

Future<Tuple2<int, List<GameMatch>>> getMatchesRequest() async {
  try {
    var res = await Network.serverGet("matches/get");

    if (res.item1 && res.item3.isNotEmpty) {
      return Tuple2(res.item2, MatchesResponse.fromJson(res.item3).matches);
    } else {
      return Tuple2(res.item2, []);
    }
  } catch (e) {
    Logger().e(e);
    return const Tuple2(HttpStatus.badRequest, []);
  }
}

Future<Tuple2<int, GameMatch?>> getMatchRequest(String matchNumber) async {
  try {
    var message = MatchRequest(matchNumber: matchNumber).toJson();
    var res = await Network.serverPost("match/get", message);

    if (res.item1 && res.item3.isNotEmpty) {
      try {
        var match = MatchResponse.fromJson(res.item3).gameMatch;
        return Tuple2(res.item2, match);
      } catch (e) {
        Logger().e(e);
        return const Tuple2(HttpStatus.badRequest, null);
      }
    } else {
      return Tuple2(res.item2, null);
    }
  } catch (e) {
    Logger().e(e);
    return const Tuple2(HttpStatus.badRequest, null);
  }
}

Future<int> updateMatchRequest(String originMatchNumber, GameMatch match) async {
  try {
    var message = MatchUpdateRequest(authToken: await NetworkAuth.getToken(), matchNumber: originMatchNumber, matchData: match);
    var res = await Network.serverPost("match/update", message.toJson());
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

Future<int> loadMatchRequest(List<String> matchNumbers) async {
  try {
    var message = MatchLoadRequest(authToken: await NetworkAuth.getToken(), matchNumbers: matchNumbers);
    var res = await Network.serverPost("match/load", message.toJson());

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

Future<int> unloadMatchRequest() async {
  try {
    var message = MatchLoadRequest(authToken: await NetworkAuth.getToken(), matchNumbers: []);
    var res = await Network.serverPost("match/unload", message.toJson());

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

Future<int> deleteMatchRequest(String matchNumber) async {
  try {
    var message = MatchDeleteRequest(authToken: await NetworkAuth.getToken(), matchNumber: matchNumber);
    var res = await Network.serverPost("match/delete", message);

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
