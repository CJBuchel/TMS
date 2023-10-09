import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/matches/delete_match.dart';
import 'package:tms/views/admin/dashboard/matches/edit_match.dart';
import 'package:tms/views/admin/dashboard/matches/edit_on_table.dart';

class MatchEditRow extends StatelessWidget {
  final GameMatch match;
  final List<Team> teams;

  const MatchEditRow({Key? key, required this.match, required this.teams}) : super(key: key);

  Team? _getTeam(String teamNumber) {
    // safely find team
    final index = teams.indexWhere((t) => t.teamNumber == teamNumber);
    if (index != -1) {
      return teams[index];
    } else {
      return null;
    }
  }

  Widget _styledTextCell(String label, {Color? color}) {
    return Container(
      color: color,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<Widget> _getOnTableRow(List<OnTable> tables) {
    return tables.expand((table) {
      return [
        // table cell
        Expanded(
          child: _styledTextCell(
            table.table,
            color: match.complete && !table.scoreSubmitted
                ? Colors.red
                : table.scoreSubmitted
                    ? Colors.green
                    : null,
          ),
        ),

        // team cell
        Expanded(
          child: _styledTextCell(
            table.teamNumber,
            color: match.complete && !table.scoreSubmitted
                ? Colors.red
                : table.scoreSubmitted
                    ? Colors.green
                    : null,
          ),
        ),
      ];
    }).toList();
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
            child: DeleteMatch(onDeleteMatch: () {}, matchNumber: match.matchNumber),
          ),

          // match number
          Expanded(
            flex: 1,
            child: _styledTextCell(match.matchNumber.toString()),
          ),

          Expanded(
            flex: 1,
            child: _styledTextCell(match.roundNumber.toString()),
          ),

          Expanded(
            flex: 1,
            child: _styledTextCell(match.startTime),
          ),
          Expanded(child: EditMatch(onEditMatch: () {}, match: match)),

          ..._getOnTableRow(match.matchTables),

          EditOnTable(match: match, onTableChanged: (tables) {}),
          // Edit button
        ],
      ),
    );
  }
}
