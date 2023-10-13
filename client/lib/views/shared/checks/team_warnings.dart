import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/checks/team_warning_checks.dart';

class SingleTeamWarnings extends StatefulWidget {
  final double? fontSize;
  final Team team;
  final Event? event;

  const SingleTeamWarnings({
    Key? key,
    required this.team,
    required this.event,
    this.fontSize,
  }) : super(key: key);

  @override
  State<SingleTeamWarnings> createState() => _SingleTeamWarningsState();
}

class _SingleTeamWarningsState extends State<SingleTeamWarnings> {
  List<TeamWarning> _warnings = [];

  void setWarnings() {
    _warnings = SingleTeamWarningChecks.getWarnings(
      team: widget.team,
      event: widget.event,
    );
  }

  @override
  void didUpdateWidget(covariant SingleTeamWarnings oldWidget) {
    super.didUpdateWidget(oldWidget);
    setWarnings();
  }

  @override
  void initState() {
    super.initState();
    setWarnings();
  }

  String? getTooltips(TeamWarning e) {
    if (e.teamNumber != null) {
      return "Team ${e.teamNumber}: ${e.message}";
    } else {
      return e.message;
    }
  }

  Widget checkWarnings() {
    if (_warnings.isEmpty) {
      return Text(
        "Warnings: 0",
        style: TextStyle(
          fontSize: widget.fontSize,
        ),
      );
    } else {
      return Tooltip(
        message: _warnings.map((e) => getTooltips(e)).join("\n"),
        child: Row(
          children: [
            Text(
              "Errors: ${_warnings.length}",
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
