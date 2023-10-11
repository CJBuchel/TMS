import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/parse_util.dart';

class MatchWarning {
  final String message;
  final String? matchNumber;
  final String? teamNumber;

  MatchWarning({
    required this.message,
    this.matchNumber,
    this.teamNumber,
  });
}

class MatchWarnings extends StatefulWidget {
  final List<GameMatch> matches;
  final List<Team> teams;
  final List<JudgingSession> judgingSessions;
  final Event? event;
  final double? fontSize;
  final Function(List<MatchWarning>)? onWarnings;

  const MatchWarnings({
    Key? key,
    required this.matches,
    required this.teams,
    required this.judgingSessions,
    required this.event,
    this.fontSize,
    this.onWarnings,
  }) : super(key: key);

  @override
  State<MatchWarnings> createState() => _MatchWarningsState();
}

class _MatchWarningsState extends State<MatchWarnings> {
  List<MatchWarning> _warnings = [];

  List<MatchWarning> roundWarnings() {
    List<MatchWarning> warnings = [];

    int rounds = widget.event?.eventRounds ?? 0;

    for (var match in widget.matches) {
      if (match.roundNumber == 0 && !match.exhibitionMatch) {
        warnings.add(MatchWarning(message: "Round is 0 and is not marked as exhibition", matchNumber: match.matchNumber));
      } else if (match.roundNumber > rounds) {
        warnings.add(MatchWarning(message: "Round is greater than the number of rounds", matchNumber: match.matchNumber));
      }
    }

    return warnings;
  }

  List<MatchWarning> onTableWarnings() {
    List<MatchWarning> warnings = [];
    for (var match in widget.matches) {
      // check on the tables
      for (var onTable in match.matchTables) {
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

  List<MatchWarning> teamWarnings() {
    List<MatchWarning> warnings = [];

    Map<String, List<TimeOfDay>> judgingTimesByTeam = {};

    // add judging times to map
    for (var session in widget.judgingSessions) {
      for (var pod in session.judgingPods) {
        var sessionTime = parseStringTimeToTimeOfDay(session.startTime) ?? TimeOfDay.now();

        if (!judgingTimesByTeam.containsKey(pod.teamNumber)) {
          judgingTimesByTeam[pod.teamNumber] = []; // add team to map if not already there
        }

        judgingTimesByTeam[pod.teamNumber]!.add(sessionTime);
      }
    }

    // check if team has judging session within 10 minutes of match
    for (var match in widget.matches) {
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

  void setWarnings() {
    _warnings = [
      ...roundWarnings(),
      ...onTableWarnings(),
      ...teamWarnings(),
    ];

    if (widget.onWarnings != null) {
      widget.onWarnings!.call(_warnings);
    }
  }

  @override
  void initState() {
    super.initState();
    setWarnings();
  }

  @override
  void didUpdateWidget(covariant MatchWarnings oldWidget) {
    super.didUpdateWidget(oldWidget);
    setWarnings();
  }

  // can only ever be either match error or team error
  String? getTooltips(MatchWarning e) {
    if (e.matchNumber != null) {
      return "Match ${e.matchNumber}: ${e.message}";
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
        style: TextStyle(fontSize: widget.fontSize),
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
            child: Icon(Icons.warning, color: Colors.orange, size: widget.fontSize),
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
