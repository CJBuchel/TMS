import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/matches/checks/errors.dart';
import 'package:tms/views/admin/dashboard/matches/checks/warnings.dart';
import 'package:tms/views/admin/dashboard/matches/on_tables/edit_on_tables.dart';
import 'package:tms/views/admin/dashboard/matches/match_edit/delete_match.dart';
import 'package:tms/views/admin/dashboard/matches/match_edit/edit_match.dart';

class MatchEditRow extends StatelessWidget {
  final GameMatch match;
  final List<Team> teams;
  final Color rowColor;

  final List<MatchWarning> warnings;
  final List<MatchError> errors;

  const MatchEditRow({
    Key? key,
    required this.match,
    required this.teams,
    required this.rowColor,
    required this.warnings,
    required this.errors,
  }) : super(key: key);

  Widget _styledTextCell(String label, {Color? color, Color? textColor}) {
    return Container(
      color: color,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _styledCell(Widget inner, {Color? color}) {
    return Container(
      color: color,
      child: Center(
        child: inner,
      ),
    );
  }

  Widget _getOnTableRow(List<OnTable> tables, {Color? color}) {
    List<Widget> onTableRows = [];

    for (var table in tables) {
      // table cells
      onTableRows.add(
        Expanded(
          flex: 1,
          child: _styledTextCell(
            table.table,
            color: match.complete && !table.scoreSubmitted
                ? Colors.red
                : table.scoreSubmitted
                    ? Colors.green
                    : color,
          ),
        ),
      );

      // team cell
      onTableRows.add(
        Expanded(
          flex: 1,
          child: _styledTextCell(
            table.teamNumber,
            color: match.complete && !table.scoreSubmitted
                ? Colors.red
                : table.scoreSubmitted
                    ? Colors.green
                    : color,
          ),
        ),
      );
    }

    return Row(
      children: onTableRows,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Delete button
          Expanded(
            flex: 1,
            child: _styledCell(DeleteMatch(matchNumber: match.matchNumber)),
          ),

          // match number
          Expanded(
            flex: 1,
            child: _styledTextCell(match.matchNumber.toString(), color: rowColor),
          ),

          Expanded(
            flex: 1,
            child: _styledTextCell(match.roundNumber.toString(), color: rowColor),
          ),

          Expanded(
            flex: 2,
            child: _styledTextCell(match.startTime, color: rowColor),
          ),

          // edit the match
          Expanded(
            flex: 1,
            child: EditMatch(matchNumber: match.matchNumber),
          ),

          // table info
          Expanded(
            flex: 2,
            child: _getOnTableRow(match.matchTables, color: rowColor),
          ),

          // edit the tables
          Expanded(
            flex: 1,
            child: _styledCell(EditOnTables(matchNumber: match.matchNumber, teams: teams)),
          ),
          // Edit button
        ],
      ),
    );
  }
}
