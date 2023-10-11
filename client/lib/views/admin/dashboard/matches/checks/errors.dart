import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';

class MatchError {
  final String message;
  final String? matchNumber;
  final String? teamNumber;

  MatchError({
    required this.message,
    this.matchNumber,
    this.teamNumber,
  });
}

class MatchErrors extends StatefulWidget {
  final List<GameMatch> matches;
  final List<Team> teams;
  final Event? event;
  final double? fontSize;
  final Function(List<MatchError>)? onErrors;

  const MatchErrors({
    Key? key,
    required this.matches,
    required this.teams,
    required this.event,
    this.fontSize,
    this.onErrors,
  }) : super(key: key);

  @override
  State<MatchErrors> createState() => _MatchErrorsState();
}

class _MatchErrorsState extends State<MatchErrors> {
  List<MatchError> _errors = [];

  List<MatchError> onTableErrors() {
    List<MatchError> errors = [];
    List<String> tables = widget.event?.tables ?? [];
    for (var match in widget.matches) {
      // check on the tables
      for (var onTable in match.matchTables) {
        // check if table is blank
        if (onTable.table.isNotEmpty && !tables.contains(onTable.table)) {
          errors.add(MatchError(message: "Table ${onTable.table} does not exist in this event", matchNumber: match.matchNumber));
        }
      }
    }
    return errors;
  }

  List<MatchError> teamErrors() {
    List<MatchError> errors = [];

    int rounds = widget.event?.eventRounds ?? 0;
    for (var team in widget.teams) {
      int teamMatches = 0;
      for (var match in widget.matches) {
        for (var onTable in match.matchTables) {
          if (onTable.teamNumber == team.teamNumber) {
            teamMatches++;
          }
        }
      }

      if (teamMatches < rounds) {
        errors.add(MatchError(message: "Team has less matches than the number of rounds", teamNumber: team.teamNumber));
      } else if (teamMatches > rounds) {
        errors.add(MatchError(message: "Team has more matches than the number of rounds", teamNumber: team.teamNumber));
      }
    }

    return errors;
  }

  void setErrors() {
    _errors = [
      ...onTableErrors(),
      ...teamErrors(),
    ];

    if (widget.onErrors != null) {
      widget.onErrors!.call(_errors);
    }
  }

  @override
  void initState() {
    super.initState();
    setErrors();
  }

  @override
  void didUpdateWidget(covariant MatchErrors oldWidget) {
    super.didUpdateWidget(oldWidget);
    setErrors();
  }

  // can only ever be either match error or team error
  String? getTooltips(MatchError e) {
    if (e.matchNumber != null) {
      return "Match ${e.matchNumber}: ${e.message}";
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
        style: TextStyle(fontSize: widget.fontSize),
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
            child: Icon(Icons.warning, color: Colors.red, size: widget.fontSize),
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
