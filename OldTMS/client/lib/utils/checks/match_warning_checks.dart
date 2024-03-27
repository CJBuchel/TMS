import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/parse_util.dart';

class MatchWarning {
  final String message;
  final String? matchNumber;
  final String? teamNumber;

  const MatchWarning({
    required this.message,
    this.matchNumber,
    this.teamNumber,
  });
}

class MatchWarningChecks {
  static List<GameMatch> _matches = [];
  static List<JudgingSession> _judgingSessions = [];
  static Event? _event;

  static List<MatchWarning> _roundWarnings() {
    List<MatchWarning> warnings = [];

    int rounds = _event?.eventRounds ?? 0;

    for (var match in _matches) {
      if (match.roundNumber == 0 && !match.exhibitionMatch) {
        warnings.add(MatchWarning(message: "Round is 0 and is not marked as exhibition", matchNumber: match.matchNumber));
      } else if (match.roundNumber > rounds) {
        warnings.add(MatchWarning(message: "Round is greater than the number of rounds", matchNumber: match.matchNumber));
      }
    }

    return warnings;
  }

  static List<MatchWarning> _onTableWarnings() {
    List<MatchWarning> warnings = [];
    for (var match in _matches) {
      // check on the tables
      if (match.matchTables.isEmpty) {
        warnings.add(MatchWarning(message: "No tables or teams specified for match", matchNumber: match.matchNumber));
      }

      for (var onTable in match.matchTables) {
        if (onTable.scoreSubmitted && !match.complete) {
          warnings.add(MatchWarning(message: "Score submitted but match is not complete", matchNumber: match.matchNumber));
        }

        // check if table is blank
        if (onTable.table.isEmpty) {
          warnings.add(MatchWarning(message: "No table specified", matchNumber: match.matchNumber));
        }

        // check if team is blank
        if (onTable.teamNumber.isEmpty) {
          warnings.add(MatchWarning(message: "No team on table ${onTable.table}", matchNumber: match.matchNumber));
        }
      }
    }

    return warnings;
  }

  static List<MatchWarning> _teamWarnings() {
    List<MatchWarning> warnings = [];

    Map<String, List<TimeOfDay>> judgingTimesByTeam = {};

    // add judging times to map
    for (var session in _judgingSessions) {
      for (var pod in session.judgingPods) {
        var sessionTime = parseStringTimeToTimeOfDay(session.startTime) ?? TimeOfDay.now();

        if (!judgingTimesByTeam.containsKey(pod.teamNumber)) {
          judgingTimesByTeam[pod.teamNumber] = []; // add team to map if not already there
        }

        judgingTimesByTeam[pod.teamNumber]!.add(sessionTime);
      }
    }

    // check if team has judging session within 10 minutes of match
    for (var match in _matches) {
      for (var onTable in match.matchTables) {
        TimeOfDay matchTime = parseStringTimeToTimeOfDay(match.startTime) ?? TimeOfDay.now();

        if (judgingTimesByTeam.containsKey(onTable.teamNumber)) {
          for (var sessionTime in judgingTimesByTeam[onTable.teamNumber]!) {
            if (matchTime.hour == sessionTime.hour && (matchTime.minute - sessionTime.minute).abs() <= 10) {
              warnings.add(
                MatchWarning(
                  message: "Team ${onTable.teamNumber} has a judging session within 10 minutes of match ${match.matchNumber}",
                  teamNumber: onTable.teamNumber,
                ),
              );
            }
          }
        }
      }
    }

    return warnings;
  }

  static List<MatchWarning> getWarnings({
    required List<GameMatch> matches,
    required List<JudgingSession> judgingSessions,
    required Event? event,
  }) {
    _matches = matches;
    _judgingSessions = judgingSessions;
    _event = event;
    return [
      ..._roundWarnings(),
      ..._onTableWarnings(),
      ..._teamWarnings(),
    ];
  }
}
