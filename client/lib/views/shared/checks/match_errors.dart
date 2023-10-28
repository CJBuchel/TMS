import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/checks/match_error_checks.dart';

class MatchErrors extends StatefulWidget {
  final List<GameMatch> matches;
  final List<Team> teams;
  final Event? event;
  final double? fontSize;

  const MatchErrors({
    Key? key,
    required this.matches,
    required this.teams,
    required this.event,
    this.fontSize,
  }) : super(key: key);

  @override
  State<MatchErrors> createState() => _MatchErrorsState();
}

class _MatchErrorsState extends State<MatchErrors> {
  List<MatchError> _errors = [];

  void setErrors() {
    _errors = MatchErrorChecks.getErrors(
      matches: widget.matches,
      teams: widget.teams,
      event: widget.event,
    );
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

  String? getTooltips(MatchError e) {
    if (e.matchNumber != null && e.teamNumber != null) {
      return "Match ${e.matchNumber} - Team ${e.teamNumber}: ${e.message}";
    } else if (e.matchNumber != null) {
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
