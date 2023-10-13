import 'package:tms/schema/tms_schema.dart';

class JudgingError {
  final String message;
  final String? sessionNumber;
  final String? teamNumber;

  const JudgingError({
    required this.message,
    this.sessionNumber,
    this.teamNumber,
  });
}

class JudgingErrorChecks {
  static List<Team> _teams = [];
  static List<JudgingSession> _judgingSessions = [];
  static Event? _event;

  static List<JudgingError> _podErrors() {
    List<JudgingError> errors = [];
    List<String> pods = _event?.pods ?? [];
    for (var session in _judgingSessions) {
      for (var pod in session.judgingPods) {
        if (pod.pod.isNotEmpty && !pods.contains(pod.pod)) {
          errors.add(JudgingError(message: "Pod ${pod.pod} does not exist in this event", sessionNumber: session.sessionNumber));
        }
      }
    }

    return errors;
  }

  static List<JudgingError> _teamErrors() {
    List<JudgingError> errors = [];

    for (var team in _teams) {
      int teamSessions = 0;
      for (var session in _judgingSessions) {
        for (var pod in session.judgingPods) {
          if (pod.teamNumber == team.teamNumber) {
            teamSessions++;
          }
        }
      }

      if (teamSessions == 0) {
        errors.add(JudgingError(message: "Team is not in any judging sessions", teamNumber: team.teamNumber));
      } else if (teamSessions > 1) {
        errors.add(JudgingError(message: "Team is in more than one judging session", teamNumber: team.teamNumber));
      }
    }

    return errors;
  }

  static List<JudgingError> getErrors({
    required List<Team> teams,
    required List<JudgingSession> judgingSessions,
    required Event? event,
  }) {
    _teams = teams;
    _judgingSessions = judgingSessions;
    _event = event;
    return [
      ..._podErrors(),
      ..._teamErrors(),
    ];
  }
}
