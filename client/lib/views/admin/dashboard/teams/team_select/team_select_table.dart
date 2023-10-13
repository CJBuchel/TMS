import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/checks/team_error_checks.dart';
import 'package:tms/utils/checks/team_warning_checks.dart';

class TeamSelectTable extends StatefulWidget {
  final Event? event;
  final List<Team> teams;
  final Function(Team) onTeamSelected;

  const TeamSelectTable({
    Key? key,
    required this.event,
    required this.teams,
    required this.onTeamSelected,
  }) : super(key: key);

  @override
  State<TeamSelectTable> createState() => _TeamSelectTableState();
}

class _TeamSelectTableState extends State<TeamSelectTable> {
  Team? _selected;

  set setSelected(Team t) {
    if (mounted) {
      setState(() {
        _selected = t;
      });
      widget.onTeamSelected(t);
    }
  }

  Widget _styledCell(Widget inner, {Color? color}) {
    return Container(
      color: color,
      child: Center(
        child: inner,
      ),
    );
  }

  Widget _styledTextCell(String label, {Color? color, Color? textColor}) {
    return _styledCell(
      color: color,
      Text(
        label,
        style: TextStyle(
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget warningsTooltip(List<TeamWarning> warnings) {
    return Tooltip(
      message: warnings.map((e) => "${e.teamNumber}: ${e.message}").join("\n"),
      child: const Icon(
        Icons.info_outline,
        color: Colors.orange,
      ),
    );
  }

  Widget errorsToolTip(List<TeamError> errors) {
    return Tooltip(
      message: errors.map((e) => "${e.teamNumber}: ${e.message}").join("\n"),
      child: const Icon(
        Icons.info_outline,
        color: Colors.red,
      ),
    );
  }

  Widget _getRow(Team t, {Color? color}) {
    List<TeamWarning> warnings = SingleTeamWarningChecks.getWarnings(team: t, event: widget.event);
    List<TeamError> errors = SingleTeamErrorChecks.getWarnings(team: t);

    return InkWell(
      onTap: () => setSelected = t,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: _styledTextCell(t.ranking.toString(), color: color),
          ),
          Expanded(
            flex: 2,
            child: _styledTextCell("${t.teamNumber} | ${t.teamName}", color: color),
          ),
          Expanded(
            flex: 1,
            child: _styledCell(
              color: color,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (warnings.isNotEmpty) warningsTooltip(warnings),
                  if (errors.isNotEmpty) errorsToolTip(errors),
                  if (errors.isEmpty && warnings.isEmpty) const Icon(Icons.check, color: Colors.green),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.teams.length,
      itemBuilder: ((context, index) {
        Color rowColor = Colors.transparent;

        if (_selected?.teamNumber == widget.teams[index].teamNumber) {
          rowColor = Colors.blue[300] ?? Colors.transparent;
        } else if (index.isEven) {
          rowColor = Theme.of(context).splashColor;
        } else {
          rowColor = Theme.of(context).colorScheme.secondary.withOpacity(0.1);
        }

        return Container(
          decoration: BoxDecoration(
            color: rowColor,
            border: const Border(
              bottom: BorderSide(
                color: Colors.grey,
              ),
            ),
          ),
          height: 50,
          child: _getRow(widget.teams[index], color: rowColor),
        );
      }),
    );
  }
}
