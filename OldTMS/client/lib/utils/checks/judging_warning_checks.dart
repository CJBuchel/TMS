import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/parse_util.dart';

class JudgingWarning {
  final String message;
  final String? sessionNumber;
  final String? teamNumber;

  const JudgingWarning({
    required this.message,
    this.sessionNumber,
    this.teamNumber,
  });
}

class JudgingWarningChecks {
  static List<GameMatch> _matches = [];
  static List<JudgingSession> _judgingSessions = [];

  static List<JudgingWarning> _podWarnings() {
    List<JudgingWarning> warnings = [];
    for (var session in _judgingSessions) {
      if (session.judgingPods.isEmpty) {
        warnings.add(JudgingWarning(message: "Session has no pods", sessionNumber: session.sessionNumber));
      }

      for (var pod in session.judgingPods) {
        if (pod.pod.isEmpty) {
          warnings.add(JudgingWarning(message: "Pod with no name", sessionNumber: session.sessionNumber));
        }
        if (pod.teamNumber.isEmpty) {
          warnings.add(JudgingWarning(message: "No team in pod ${pod.pod}", sessionNumber: session.sessionNumber));
        }
      }
    }

    return warnings;
  }

  static List<JudgingWarning> _teamWarnings() {
    List<JudgingWarning> warnings = [];

    Map<String, List<TimeOfDay>> matchTimesByTeam = {};

    // add match times to map
    for (var match in _matches) {
      for (var table in match.matchTables) {
        var sessionTime = parseStringTimeToTimeOfDay(match.startTime) ?? TimeOfDay.now();

        if (!matchTimesByTeam.containsKey(table.teamNumber)) {
          matchTimesByTeam[table.teamNumber] = [];
        }

        matchTimesByTeam[table.teamNumber]!.add(sessionTime);
      }
    }

    // check if team has match within 10 minutes of judging session
    for (var session in _judgingSessions) {
      for (var pod in session.judgingPods) {
        TimeOfDay sessionTime = parseStringTimeToTimeOfDay(session.startTime) ?? TimeOfDay.now();

        if (matchTimesByTeam.containsKey(pod.teamNumber)) {
          for (var matchTime in matchTimesByTeam[pod.teamNumber]!) {
            if (sessionTime.hour == matchTime.hour && (sessionTime.minute - matchTime.minute).abs() <= 10) {
              warnings.add(
                JudgingWarning(
                  message: "Team ${pod.teamNumber} has a match within 10 minutes of judging session ${session.sessionNumber}",
                  teamNumber: pod.teamNumber,
                ),
              );
            }
          }
        }
      }
    }

    return warnings;
  }

  static List<JudgingWarning> getWarnings({
    required List<GameMatch> matches,
    required List<JudgingSession> judgingSessions,
  }) {
    _matches = matches;
    _judgingSessions = judgingSessions;
    return [
      ..._podWarnings(),
      ..._teamWarnings(),
    ];
  }
}
