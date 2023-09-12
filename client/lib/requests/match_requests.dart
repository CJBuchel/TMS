import 'package:logger/logger.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tuple/tuple.dart';

Future<Tuple2<int, List<GameMatch>>> getMatchesRequest() async {
  try {
    var res = await Network.serverGet("matches/get");

    if (res.item1) {
      return Tuple2(res.item2, MatchesResponse.fromJson(res.item3).matches);
    } else {
      return Tuple2(res.item2, []);
    }
  } catch (e) {
    Logger().e(e);
    rethrow;
  }
}

Future<Tuple2<int, GameMatch?>> getMatchRequest(String matchNUmber) async {
  try {
    var message = MatchRequest(matchNumber: matchNUmber).toJson();
    var res = await Network.serverPost("match/get", message);

    if (res.item1) {
      return Tuple2(res.item2, GameMatch.fromJson(res.item3));
    } else {
      return Tuple2(res.item2, null);
    }
  } catch (e) {
    Logger().e(e);
    rethrow;
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
    rethrow;
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
    rethrow;
  }
}
