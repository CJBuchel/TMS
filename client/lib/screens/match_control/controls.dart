import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/screens/match_control/ttl_clock.dart';

class MatchControlControls extends StatefulWidget {
  final BoxConstraints con;
  final List<Team> teams;
  final List<GameMatch> matches;
  final List<GameMatch> selectedMatches;
  const MatchControlControls({Key? key, required this.con, required this.teams, required this.selectedMatches, required this.matches})
      : super(key: key);

  @override
  _MatchControlControlsState createState() => _MatchControlControlsState();
}

class _MatchControlControlsState extends State<MatchControlControls> {
  Widget _styledHeader(String content) {
    return Text(content, style: const TextStyle(fontWeight: FontWeight.bold));
  }

  DataCell _styledCell(String context) {
    return DataCell(
      Text(
        context,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  DataRow2 _styledRow(OnTable table, String matchNumber) {
    return DataRow2(cells: [
      _styledCell(matchNumber),
      _styledCell(table.table),
      _styledCell(table.teamNumber),
      _styledCell(widget.teams.firstWhere((t) => t.teamNumber == table.teamNumber).teamName),
    ]);
  }

  List<DataRow2> _getRows() {
    List<DataRow2> rows = [];
    for (var match in widget.selectedMatches) {
      rows.add(_styledRow(match.onTableFirst, match.matchNumber));
      rows.add(_styledRow(match.onTableSecond, match.matchNumber));
    }
    return rows;
  }

  Widget getControls() {
    return Center(
      child: Column(
        children: [
          // TTL Clock
          Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 3.0,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                ),
                bottom: BorderSide(
                  width: 3.0,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                ),
              ),
            ),
            child: Center(
              child: TTLClock(matches: widget.matches),
            ),
          ),

          // Status of Match
          // ElevatedButton(
          //   onPressed: () {},
          //   child: const Text("Start Matches"),
          // ),
        ],
      ),
    );
  }

  Widget getStagingTable() {
    if (widget.selectedMatches.isEmpty) {
      return const Center(child: Text("No Matches Staged", style: TextStyle(fontSize: 45)));
    } else {
      return DataTable2(
        headingRowColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
          return Colors.transparent;
        }),
        columnSpacing: 10,
        columns: [
          DataColumn2(label: _styledHeader("Match"), size: ColumnSize.S),
          DataColumn2(label: _styledHeader("Table")),
          DataColumn2(label: _styledHeader("Team")),
          DataColumn2(label: _styledHeader("Name"), size: ColumnSize.L),
        ],
        rows: _getRows(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.con.maxHeight / 3,
          child: getStagingTable(),
        ),
        SizedBox(
          height: (widget.con.maxHeight / 3) * 2,
          child: getControls(),
        )
      ],
    );
  }
}
