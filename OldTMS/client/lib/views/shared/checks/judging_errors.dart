import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/checks/judging_error_checks.dart';

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

  void setErrors() {
    _errors = JudgingErrorChecks.getErrors(
      judgingSessions: widget.judgingSessions,
      teams: widget.teams,
      event: widget.event,
    );
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
