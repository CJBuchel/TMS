import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/matches/on_tables/drop_down_table.dart';
import 'package:tms/views/admin/dashboard/matches/on_tables/drop_down_team.dart';
import 'package:tms/views/admin/dashboard/matches/on_tables/score_submitted_checkbox.dart';

class OnTables extends StatefulWidget {
  final GameMatch match;
  final List<Team> teams;
  final Function(GameMatch) onMatchUpdate;
  const OnTables({
    Key? key,
    required this.match,
    required this.teams,
    required this.onMatchUpdate,
  }) : super(key: key);

  @override
  State<OnTables> createState() => _OnTablesState();
}

class _OnTablesState extends State<OnTables> {
  @override
  void initState() {
    super.initState();
  }

  Widget _styledHeader(String content) {
    return Center(child: Text(content, style: const TextStyle(fontWeight: FontWeight.bold)));
  }

  DataRow2 _styledRow(OnTable table) {
    return DataRow2(cells: [
      // delete on table
      DataCell(
        Center(
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              // remove on table
              final index = widget.match.matchTables.indexWhere((t) => t.table == table.table);
              if (index != -1) {
                GameMatch updatedMatch = widget.match;
                setState(() {
                  updatedMatch.matchTables.removeAt(index);
                  widget.onMatchUpdate(updatedMatch);
                });
              }
            },
          ),
        ),
      ),

      // table cell
      DataCell(
        Center(
          child: DropdownTable(
            match: widget.match,
            onTable: table,
            onTableUpdate: (m) {
              widget.onMatchUpdate(m);
            },
          ),
        ),
      ),

      // team cell
      DataCell(Center(
        child: DropdownTeam(
          match: widget.match,
          teams: widget.teams,
          onTable: table,
          onTableUpdate: (m) {
            widget.onMatchUpdate(m);
          },
        ),
      )),

      // submitted cell
      DataCell(
        Center(
          child: ScoreSubmittedCheckbox(
            onTable: table,
            match: widget.match,
            onTableUpdate: (m) {
              widget.onMatchUpdate(m);
            },
          ),
        ),
      )
    ]);
  }

  List<DataRow2> _getRows() {
    List<DataRow2> rows = widget.match.matchTables.map((e) => _styledRow(e)).toList();
    rows.add(
      DataRow2(cells: [
        DataCell(
          Center(
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.green),
              onPressed: () {
                // add on table
                GameMatch updatedMatch = widget.match;
                setState(() {
                  updatedMatch.matchTables.add(OnTable(table: "", teamNumber: "", scoreSubmitted: false));
                  widget.onMatchUpdate(updatedMatch);
                });
              },
            ),
          ),
        ),
        const DataCell(SizedBox.shrink()),
        const DataCell(SizedBox.shrink()),
        const DataCell(SizedBox.shrink()),
      ]),
    );
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return DataTable2(
      headingRowColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
        return Colors.transparent;
      }),
      columnSpacing: 10,
      columns: [
        const DataColumn2(label: SizedBox.shrink(), size: ColumnSize.S), // delete button
        DataColumn2(label: _styledHeader("Table"), size: ColumnSize.L),
        DataColumn2(label: _styledHeader("Team"), size: ColumnSize.L),
        DataColumn2(label: _styledHeader("Submitted"), size: ColumnSize.S),
      ],
      rows: _getRows(),
    );
  }
}
