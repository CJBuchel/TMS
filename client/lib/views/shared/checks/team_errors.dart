import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/checks/team_error_checks.dart';

class SingleTeamErrors extends StatefulWidget {
  final double? fontSize;
  final Team team;
  final Event? event;

  const SingleTeamErrors({
    Key? key,
    required this.team,
    required this.event,
    this.fontSize,
  }) : super(key: key);

  @override
  State<SingleTeamErrors> createState() => _SingleTeamErrorsState();
}

class _SingleTeamErrorsState extends State<SingleTeamErrors> {
  List<TeamError> _errors = [];

  void setErrors() {
    _errors = SingleTeamErrorChecks.getWarnings(
      team: widget.team,
    );
  }

  @override
  void didUpdateWidget(covariant SingleTeamErrors oldWidget) {
    super.didUpdateWidget(oldWidget);
    setErrors();
  }

  @override
  void initState() {
    super.initState();
    setErrors();
  }

  String? getTooltips(TeamError e) {
    if (e.teamNumber != null) {
      return "Team ${e.teamNumber}: ${e.message}";
    } else {
      return e.message;
    }
  }

  Widget checkWarnings() {
    if (_errors.isEmpty) {
      return Text(
        "Errors: 0",
        style: TextStyle(
          fontSize: widget.fontSize,
        ),
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
          child: checkWarnings(),
        ),
      ],
    );
  }
}
