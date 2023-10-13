import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/checks/judging_warning_checks.dart';

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

  void setWarnings() {
    _warnings = JudgingWarningChecks.getWarnings(
      matches: widget.matches,
      judgingSessions: widget.judgingSessions,
    );
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
