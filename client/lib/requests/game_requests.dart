import 'dart:io';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tuple/tuple.dart';

Future<Tuple2<int, Game?>> getGameRequest() async {
  try {
    var res = await Network.serverGet("game/get");

    if (res.item1 && res.item3.isNotEmpty) {
      return Tuple2(res.item2, GameResponse.fromJson(res.item3).game);
    } else {
      return Tuple2(res.item2, null);
    }
  } catch (e) {
    return const Tuple2(HttpStatus.badRequest, null);
  }
}

Future<Tuple2<int, List<Mission>>> getMissionsRequest() async {
  try {
    var res = await Network.serverGet("missions/get");

    if (res.item1 && res.item3.isNotEmpty) {
      return Tuple2(res.item2, MissionsResponse.fromJson(res.item3).missions);
    } else {
      return Tuple2(res.item2, []);
    }
  } catch (e) {
    return const Tuple2(HttpStatus.badRequest, []);
  }
}

Future<Tuple2<int, List<Score>>> getQuestions() async {
  try {
    var res = await Network.serverGet("questions/get");

    if (res.item1 && res.item3.isNotEmpty) {
      return Tuple2(res.item2, QuestionsResponse.fromJson(res.item3).questions);
    } else {
      return Tuple2(res.item2, []);
    }
  } catch (e) {
    return const Tuple2(HttpStatus.badRequest, []);
  }
}
