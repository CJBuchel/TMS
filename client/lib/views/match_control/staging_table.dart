import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/match_control/add_on_table.dart';
import 'package:tms/views/match_control/delete_on_table.dart';
import 'package:tms/views/match_control/edit_on_table.dart';

class StagingTable extends StatefulWidget {
  final List<Team> teams;
  final List<GameMatch> loadedMatches;
  final List<GameMatch> selectedMatches;
  const StagingTable({
    Key? key,
    required this.teams,
    required this.loadedMatches,
    required this.selectedMatches,
  }) : super(key: key);

  @override
  State<StagingTable> createState() => _StagingTableState();
}

class _StagingTableState extends State<StagingTable> with SingleTickerProviderStateMixin, AutoUnsubScribeMixin {
  late AnimationController _controller;
  final Map<String, String> _tableLoadedMatches = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 50), vsync: this)..repeat(reverse: true);

    // get table loaded matches
    autoSubscribe("table", (m) {
      setState(() {
        _tableLoadedMatches[m.subTopic] = m.message;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget styledHeader(String content) {
    return Center(child: Text(content, style: const TextStyle(fontWeight: FontWeight.bold)));
  }

  DataCell styledCell(String text) {
    return DataCell(Center(
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12),
      ),
    ));
  }

  DataCell sigCell(List<GameMatch> loadedMatches, {bool? badSig, bool? goodSig}) {
    return DataCell(
      Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: ((context, child) {
            if (loadedMatches.isNotEmpty && (badSig ?? false)) {
              return Text(
                "SIG",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _controller.value < 0.5 ? Colors.red : Colors.transparent,
                ),
              );
            } else if (loadedMatches.isNotEmpty && (goodSig ?? false)) {
              return const Text(
                "OK",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
        ),
      ),
    );
  }

  DataRow2 _styledRow(OnTable table, GameMatch match, List<Team> teams, List<GameMatch> loadedMatches, Map<String, String> tableMap) {
    // find table in tableMap and check it's match number
    bool goodSig = false;
    if (match.matchNumber == tableMap[table.table]) {
      goodSig = true;
    }

    // get team
    String teamName = teams.firstWhere((t) => t.teamNumber == table.teamNumber).teamName;

    return DataRow2(cells: [
      // delete on table
      DataCell(
        Center(
          child: DeleteOnTable(
            onTable: table,
            match: match,
          ),
        ),
      ),

      // info cells
      styledCell(match.matchNumber),
      sigCell(loadedMatches, badSig: !goodSig),
      styledCell(table.table),
      sigCell(loadedMatches, goodSig: goodSig),
      styledCell("${table.teamNumber} | $teamName"),

      // edit on table
      DataCell(
        Center(
          child: OnTableEdit(
            teams: widget.teams,
            onTable: table,
            match: match,
            selectedMatches: widget.selectedMatches,
          ),
        ),
      ),
    ]);
  }

  List<DataRow2> getRows(
    List<GameMatch> matches,
    List<GameMatch> loadedMatches,
    List<Team> teams,
    AnimationController controller,
    Map<String, String> tableMap,
  ) {
    List<DataRow2> rows = [];
    for (var match in matches) {
      for (var onTable in match.matchTables) {
        rows.add(_styledRow(onTable, match, teams, loadedMatches, tableMap));
      }
    }

    // add final row for adding another team
    rows.add(
      DataRow2(cells: [
        // delete on table
        DataCell(
          Center(
            child: OnTableAdd(
              teams: widget.teams,
              selectedMatches: widget.selectedMatches,
            ),
          ),
        ),

        // info cells
        const DataCell(SizedBox.shrink()),
        const DataCell(SizedBox.shrink()),
        const DataCell(SizedBox.shrink()),
        const DataCell(SizedBox.shrink()),
        const DataCell(SizedBox.shrink()),
        const DataCell(SizedBox.shrink()),
      ]),
    );
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    double largeFontSize = Responsive.isDesktop(context) ? 45 : 20;

    if (widget.selectedMatches.isEmpty && widget.loadedMatches.isEmpty) {
      return Center(child: Text("No Matches Staged", style: TextStyle(fontSize: largeFontSize)));
    } else {
      return DataTable2(
        headingRowColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
          return Colors.transparent;
        }),

        // columns
        columnSpacing: 10,
        columns: [
          const DataColumn2(label: SizedBox.shrink(), size: ColumnSize.S), // no title for the delete button
          DataColumn2(label: styledHeader("#"), size: ColumnSize.S),
          DataColumn2(label: styledHeader("BS"), size: ColumnSize.S), // SIG
          DataColumn2(label: styledHeader("Table")),
          DataColumn2(label: styledHeader("GS"), size: ColumnSize.S), // OK
          DataColumn2(label: styledHeader("Team"), size: ColumnSize.L),
          const DataColumn2(label: SizedBox.shrink(), size: ColumnSize.S), // no title for the edit button
        ],

        // rows
        rows: getRows(widget.selectedMatches, widget.loadedMatches, widget.teams, _controller, _tableLoadedMatches),
      );
    }
  }
}
