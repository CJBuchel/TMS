import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
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

  DataCell styledCell(String text, List<GameMatch> loadedMatches, {bool? isTable, bool? goodSig}) {
    return DataCell(
      AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if ((isTable ?? false) && loadedMatches.isNotEmpty) {
            return Container(
              color: Colors.transparent,
              // width: 100,
              child: Stack(
                children: [
                  if (!(goodSig ?? false))
                    Align(
                      alignment: Responsive.isMobile(context) ? const Alignment(-1.5, 0) : Alignment.centerLeft,
                      child: Text(
                        "SIG",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _controller.value < 0.5 ? Colors.red : Colors.transparent,
                        ),
                      ),
                    ),
                  if ((goodSig ?? false))
                    Align(
                      alignment: Responsive.isMobile(context) ? const Alignment(1.5, 0) : Alignment.centerRight,
                      child: const Text(
                        "OK",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  Center(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            );
          }
        },
      ),
    );
  }

  DataRow2 _styledRow(OnTable table, String matchNumber, List<Team> teams, List<GameMatch> loadedMatches, Map<String, String> tableMap) {
    // find table in tableMap and check it's match number
    bool goodSig = false;
    if (matchNumber == tableMap[table.table]) {
      goodSig = true;
    }
    return DataRow2(cells: [
      styledCell(matchNumber, loadedMatches),
      styledCell(table.table, loadedMatches, isTable: true, goodSig: goodSig),
      styledCell(table.teamNumber, loadedMatches),
      styledCell(teams.firstWhere((t) => t.teamNumber == table.teamNumber).teamName, loadedMatches),
      DataCell(
        Center(
          child: OnTableEdit(
            teams: widget.teams,
            onTable: table,
            matchNumber: matchNumber,
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
      rows.add(_styledRow(match.onTableFirst, match.matchNumber, teams, loadedMatches, tableMap));
      rows.add(_styledRow(match.onTableSecond, match.matchNumber, teams, loadedMatches, tableMap));
    }
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
          DataColumn2(label: styledHeader("Match"), size: ColumnSize.S),
          DataColumn2(label: styledHeader("Table")),
          DataColumn2(label: styledHeader("Team")),
          DataColumn2(label: styledHeader("Name"), size: ColumnSize.L),
          const DataColumn2(label: SizedBox.shrink()), // no title for the edit button
        ],

        // rows
        rows: getRows(widget.selectedMatches, widget.loadedMatches, widget.teams, _controller, _tableLoadedMatches),
      );
    }
  }
}
