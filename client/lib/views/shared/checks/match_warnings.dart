import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/checks/match_warning_checks.dart';

class MatchWarnings extends StatefulWidget {
  final List<GameMatch> matches;
  final List<Team> teams;
  final List<JudgingSession> judgingSessions;
  final Event? event;
  final double? fontSize;

  const MatchWarnings({
    Key? key,
    required this.matches,
    required this.teams,
    required this.judgingSessions,
    required this.event,
    this.fontSize,
  }) : super(key: key);

  @override
  State<MatchWarnings> createState() => _MatchWarningsState();
}

class _MatchWarningsState extends State<MatchWarnings> {
  List<MatchWarning> _warnings = [];

  void setWarnings() {
    _warnings = MatchWarningChecks.getWarnings(
      matches: widget.matches,
      judgingSessions: widget.judgingSessions,
      event: widget.event,
    );
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

  String? getTooltips(MatchWarning e) {
    if (e.matchNumber != null && e.teamNumber != null) {
      return "Session ${e.matchNumber} - Team ${e.teamNumber}: ${e.message}";
    } else if (e.matchNumber != null) {
      return "Session ${e.matchNumber}: ${e.message}";
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
