import 'dart:io';

import 'package:logger/logger.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tuple/tuple.dart';

Future<Tuple2<int, List<JudgingSession>>> getJudgingSessionsRequest() async {
  try {
    var res = await Network.serverGet("judging_sessions/get");

    if (res.item1 && res.item3.isNotEmpty) {
      return Tuple2(res.item2, JudgingSessionsResponse.fromJson(res.item3).judgingSessions);
    } else {
      return Tuple2(res.item2, []);
    }
  } catch (e) {
    Logger().e(e);
    return const Tuple2(HttpStatus.badRequest, []);
  }
}

Future<Tuple2<int, JudgingSession?>> getJudgingSessionRequest(String sessionNumber) async {
  try {
    var message = JudgingSessionRequest(sessionNumber: sessionNumber).toJson();
    var res = await Network.serverPost("judging_session/get", message);

    if (res.item1 && res.item3.isNotEmpty) {
      var session = JudgingSessionResponse.fromJson(res.item3).judgingSession;
      return Tuple2(res.item2, session);
    } else {
      return Tuple2(res.item2, null);
    }
  } catch (e) {
    Logger().e(e);
    return const Tuple2(HttpStatus.badRequest, null);
  }
}

Future<int> updateJudgingSessionRequest(String originSessionNumber, JudgingSession session) async {
  print("Origin number: $originSessionNumber");
  try {
    var message = JudgingSessionUpdateRequest(authToken: await NetworkAuth.getToken(), sessionNumber: originSessionNumber, judgingSession: session);
    var res = await Network.serverPost("judging_session/update", message.toJson());
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

Future<int> deleteJudgingSessionRequest(String sessionNumber) async {
  try {
    var message = JudgingSessionDeleteRequest(authToken: await NetworkAuth.getToken(), sessionNumber: sessionNumber);
    var res = await Network.serverPost("judging_session/delete", message.toJson());
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

Future<int> addJudgingSessionRequest(JudgingSession session) async {
  try {
    var message = JudgingSessionAddRequest(authToken: await NetworkAuth.getToken(), judgingSession: session);
    var res = await Network.serverPost("judging_session/add", message.toJson());
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
