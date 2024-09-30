import 'dart:io';

import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:tms/generated/infra/database_schemas/judging_session.dart';
import 'package:tms/services/judging_session_service.dart';
import 'package:tms/utils/sorter_util.dart';
import 'package:collection/collection.dart';

class JudgingSessionProvider extends EchoTreeProvider<String, JudgingSession> {
  final JudgingSessionService _service = JudgingSessionService();

  JudgingSessionProvider()
      : super(tree: ":judging:sessions", fromJsonString: (json) => JudgingSession.fromJsonString(json: json));

  List<JudgingSession> get judgingSessions => judgingSessionsByTime;

  List<JudgingSession> get judgingSessionsByNumber {
    List<JudgingSession> sessions = items.values.toList();
    return sortJudgingSessionsBySessionNumber(sessions);
  }

  List<JudgingSession> get judgingSessionsByTime {
    List<JudgingSession> sessions = items.values.toList();
    return sortJudgingSessionsByTime(sessions);
  }

  List<JudgingSession> getSessionsByTeamNumber(String teamNumber) {
    return judgingSessionsByTime.where((session) {
      return session.judgingSessionPods.any((pod) => pod.teamNumber == teamNumber);
    }).toList();
  }

  JudgingSession? getSessionBySessionNumber(String sessionNumber) {
    return items.values.firstWhereOrNull((session) => session.sessionNumber == sessionNumber);
  }

  JudgingSession? getSessionById(String id) {
    return items[id] ?? null;
  }

  String? getIdFromSessionNumber(String sessionNumber) {
    return items.keys.firstWhereOrNull((key) => items[key]?.sessionNumber == sessionNumber);
  }

  Future<int> insertJudgingSession(String? sessionNumber, JudgingSession session) async {
    String? sessionId = sessionNumber != null ? getIdFromSessionNumber(sessionNumber) : null;
    return _service.insertJudgingSession(sessionId, session);
  }

  Future<int> removeJudgingSession(String sessionNumber) async {
    String? sessionId = getIdFromSessionNumber(sessionNumber);
    if (sessionId != null) {
      return _service.removeJudgingSession(sessionId);
    } else {
      return HttpStatus.badRequest;
    }
  }

  Future<int> removePodFromSession(String pod, String sessionNumber) async {
    JudgingSession? session = items.values.firstWhereOrNull((session) => session.sessionNumber == sessionNumber);
    String? sessionId = getIdFromSessionNumber(sessionNumber);

    if (session != null && sessionId != null) {
      session.judgingSessionPods.removeWhere((p) => p.podName == pod);
      return _service.insertJudgingSession(sessionId, session);
    } else {
      return HttpStatus.badRequest;
    }
  }

  Future<int> addPodToSession(String pod, String teamNumberInPod, String sessionNumber) async {
    JudgingSession? session = items.values.firstWhereOrNull((session) => session.sessionNumber == sessionNumber);
    String? sessionId = getIdFromSessionNumber(sessionNumber);

    if (session != null && sessionId != null) {
      session.judgingSessionPods.add(JudgingSessionPod(
        podName: pod,
        teamNumber: teamNumberInPod,
        coreValuesSubmitted: false,
        innovationSubmitted: false,
        robotDesignSubmitted: false,
      ));
      return _service.insertJudgingSession(sessionId, session);
    } else {
      return HttpStatus.badRequest;
    }
  }

  Future<int> updatePodInSession({
    required String originPod,
    required String originSessionNumber,
    required JudgingSessionPod updatedPod,
    String? updatedSessionNumber,
  }) async {
    if (updatedSessionNumber != null && updatedSessionNumber != originSessionNumber) {
      // handle pod switch
      JudgingSession? originSession = items.values.firstWhereOrNull((session) {
        return session.sessionNumber == originSessionNumber;
      });
      JudgingSession? updatedSession = items.values.firstWhereOrNull((session) {
        return session.sessionNumber == updatedSessionNumber;
      });

      String? originSessionId = getIdFromSessionNumber(originSessionNumber);
      String? updatedSessionId = getIdFromSessionNumber(updatedSessionNumber);

      if (originSession != null && updatedSession != null && originSessionId != null && updatedSessionId != null) {
        originSession.judgingSessionPods.removeWhere((p) => p.podName == originPod);
        if (updatedSession.judgingSessionPods.any((p) => p.podName == updatedPod.podName)) {
          return HttpStatus.badRequest;
        } else {
          updatedSession.judgingSessionPods.add(updatedPod);
        }

        int originStatus = await _service.insertJudgingSession(originSessionId, originSession);
        int updatedStatus = await _service.insertJudgingSession(updatedSessionId, updatedSession);
        return originStatus == HttpStatus.ok && updatedStatus == HttpStatus.ok ? HttpStatus.ok : HttpStatus.badRequest;
      }
    } else {
      // handle table update
      JudgingSession? originSession = this.items.values.firstWhereOrNull((session) {
        return session.sessionNumber == originSessionNumber;
      });
      String? originSessionId = getIdFromSessionNumber(originSessionNumber);

      if (originSession != null && originSessionId != null) {
        originSession.judgingSessionPods.removeWhere((p) => p.podName == originPod);
        originSession.judgingSessionPods.add(updatedPod);
        return _service.insertJudgingSession(originSessionId, originSession);
      }
    }

    return HttpStatus.badRequest;
  }
}
