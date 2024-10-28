import 'dart:io';

import 'package:tms/generated/infra/database_schemas/judging_session.dart';
import 'package:tms/generated/infra/network_schemas/judging_session_requests.dart';
import 'package:tms/network/network.dart';
import 'package:tms/utils/logger.dart';

class JudgingSessionService {
  Future<int> insertJudgingSession(String? sessionId, JudgingSession session) async {
    try {
      var request = JudgingSessionInsertRequest(sessionId: sessionId, session: session).toJsonString();
      var response = await Network().networkPost("/judging_sessions/insert_session", request);
      if (response.$1) {
        TmsLogger().i("Inserted judging session: $session");
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> removeJudgingSession(String sessionId) async {
    try {
      var request = JudgingSessionRemoveRequest(sessionId: sessionId).toJsonString();
      var response = await Network().networkDelete("/judging_sessions/remove_session", request);
      if (response.$1) {
        TmsLogger().i("Removed judging session: $sessionId");
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
