import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/parse_util.dart';

class JudgingWarning {
  final String message;
  final String? sessionNumber;
  final String? teamNumber;

  JudgingWarning({
    required this.message,
    this.sessionNumber,
    this.teamNumber,
  });
}

class JudgingWarnings extends StatefulWidget {
  final List<GameMatch> matches;
  final List<Team> teams;
  final List<JudgingSession> judgingSessions;
  final Event? event;
  final double? fontSize;

  const JudgingWarnings({
    Key? key,
    required this.matches,
    required this.teams,
    required this.judgingSessions,
    required this.event,
    this.fontSize,
  }) : super(key: key);

  @override
  State<JudgingWarnings> createState() => _JudgingWarningsState();
}

class _JudgingWarningsState extends State<JudgingWarnings> {
  List<JudgingWarning> _warnings = [];

  List<JudgingWarning> podWarnings() {
    List<JudgingWarning> warnings = [];
    for (var session in widget.judgingSessions) {
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

  List<JudgingWarning> teamWarnings() {
    List<JudgingWarning> warnings = [];

    Map<String, List<TimeOfDay>> matchTimesByTeam = {};

    // add match times to map
    for (var match in widget.matches) {
      for (var table in match.matchTables) {
        var sessionTime = parseStringTimeToTimeOfDay(match.startTime) ?? TimeOfDay.now();

        if (!matchTimesByTeam.containsKey(table.teamNumber)) {
          matchTimesByTeam[table.teamNumber] = [];
        }

        matchTimesByTeam[table.teamNumber]!.add(sessionTime);
      }
    }

    // check if team has match within 10 minutes of judging session
    for (var session in widget.judgingSessions) {
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

  void setWarnings() {
    _warnings = [
      ...podWarnings(),
      ...teamWarnings(),
    ];
  }

  @override
  void initState() {
    super.initState();
    setWarnings();
  }

  @override
  void didUpdateWidget(covariant JudgingWarnings oldWidget) {
    super.didUpdateWidget(oldWidget);
    setWarnings();
  }

  String? getTooltips(JudgingWarning e) {
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

  Widget checkWarnings() {
    if (_warnings.isEmpty) {
      return Text(
        "Warnings: 0",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: widget.fontSize),
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return Tooltip(
        message: _warnings.map((e) => getTooltips(e)).join("\n"),
        child: Row(
          children: [
            Text(
              "Warnings: ${_warnings.length}",
              style: TextStyle(fontSize: widget.fontSize, color: Colors.orange),
              overflow: TextOverflow.ellipsis,
            ),
            Icon(
              Icons.info_outline,
              color: Colors.orange,
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
        if (_warnings.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(
              Icons.warning,
              color: Colors.orange,
              size: widget.fontSize,
            ),
          ),
        if (_warnings.isEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(Icons.check, color: Colors.green, size: widget.fontSize),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: checkWarnings(),
        ),
      ],
    );
  }
}
