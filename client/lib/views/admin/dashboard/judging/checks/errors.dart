import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';

class JudgingError {
  final String message;
  final String? sessionNumber;
  final String? teamNumber;

  JudgingError({
    required this.message,
    this.sessionNumber,
    this.teamNumber,
  });
}

class JudgingErrors extends StatefulWidget {
  final List<GameMatch> matches;
  final List<Team> teams;
  final List<JudgingSession> judgingSessions;
  final Event? event;
  final double? fontSize;

  const JudgingErrors({
    Key? key,
    required this.matches,
    required this.teams,
    required this.judgingSessions,
    required this.event,
    this.fontSize,
  }) : super(key: key);

  @override
  State<JudgingErrors> createState() => _JudgingErrorsState();
}

class _JudgingErrorsState extends State<JudgingErrors> {
  List<JudgingError> _errors = [];

  List<JudgingError> podErrors() {
    List<JudgingError> errors = [];
    List<String> pods = widget.event?.pods ?? [];
    for (var session in widget.judgingSessions) {
      for (var pod in session.judgingPods) {
        if (pod.pod.isNotEmpty && !pods.contains(pod.pod)) {
          errors.add(JudgingError(message: "Pod ${pod.pod} does not exist in this event", sessionNumber: session.sessionNumber));
        }
      }
    }

    return errors;
  }

  List<JudgingError> teamErrors() {
    List<JudgingError> errors = [];

    for (var team in widget.teams) {
      int teamSessions = 0;
      for (var session in widget.judgingSessions) {
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

  void setErrors() {
    _errors = [
      ...podErrors(),
      ...teamErrors(),
    ];
  }

  @override
  void didUpdateWidget(covariant JudgingErrors oldWidget) {
    super.didUpdateWidget(oldWidget);
    setErrors();
  }

  @override
  void initState() {
    super.initState();
    setErrors();
  }

  String? getTooltips(JudgingError e) {
    if (e.sessionNumber != null && e.teamNumber != null) {
      return "Session ${e.sessionNumber} - Team ${e.teamNumber}: ${e.message}";
    } else if (e.sessionNumber != null) {
      return "Session ${e.sessionNumber}: ${e.message}";
    } else if (e.teamNumber != null) {
      return "Team ${e.teamNumber}: ${e.message}";
    } else {
      return null;
    }
  }

  Widget checkErrors() {
    if (_errors.isEmpty) {
      return Text(
        "Errors: 0",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: widget.fontSize),
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return Tooltip(
        message: _errors.map((e) => getTooltips(e)).join("\n"),
        child: Row(
          children: [
            Text(
              "Errors: ${_errors.length}",
              style: TextStyle(fontSize: widget.fontSize, color: Colors.red),
              overflow: TextOverflow.ellipsis,
            ),
            Icon(
              Icons.info_outline,
              color: Colors.red,
              size: widget.fontSize,
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (_errors.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(
              Icons.warning,
              color: Colors.red,
              size: widget.fontSize,
            ),
          ),
        if (_errors.isEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(Icons.check, color: Colors.green, size: widget.fontSize),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: checkErrors(),
        ),
      ],
    );
  }
}
