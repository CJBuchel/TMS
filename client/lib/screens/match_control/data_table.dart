import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/schema/tms_schema.dart';

class MatchRow {
  String matchNumber;
  String startTime;

  String firstTable;
  String firstTableTeam;

  String secondTable;
  String secondTableTeam;

  bool isChecked;
  MatchRow({
    required this.matchNumber,
    required this.startTime,
    required this.firstTable,
    required this.firstTableTeam,
    required this.secondTable,
    required this.secondTableTeam,
    required this.isChecked,
  });
}

class MatchControlTable extends StatefulWidget {
  const MatchControlTable({Key? key}) : super(key: key);

  @override
  _MatchControlTableState createState() => _MatchControlTableState();
}

class _MatchControlTableState extends State<MatchControlTable> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  List<MatchRow> matches = [];

  void setMatches(List<GameMatch> gameMatches) {
    List<MatchRow> m = [];

    gameMatches.sort((a, b) => int.parse(a.matchNumber).compareTo(int.parse(b.matchNumber)));

    for (var match in gameMatches) {
      m.add(
        MatchRow(
          matchNumber: match.matchNumber,
          startTime: match.startTime,
          firstTable: match.onTableFirst.table,
          firstTableTeam: match.onTableFirst.teamNumber,
          secondTable: match.onTableSecond.table,
          secondTableTeam: match.onTableSecond.teamNumber,
          isChecked: false,
        ),
      );
    }

    setState(() {
      matches = m;
    });
  }

  Widget _styledHeader(String content) {
    return Text(content, style: const TextStyle(fontWeight: FontWeight.bold));
  }

  @override
  void initState() {
    super.initState();
    onMatchUpdate((matches) => setMatches(matches));
    getMatches().then((matches) => setMatches(matches));
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingRowColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        return Colors.transparent; // Color for header row
      }),
      columns: [
        DataColumn(label: _styledHeader('')),
        DataColumn(label: _styledHeader('Match')),
        DataColumn(label: _styledHeader('Start Time')),
        DataColumn(label: _styledHeader('Table')),
        DataColumn(label: _styledHeader('Team')),
        DataColumn(label: _styledHeader('Table')),
        DataColumn(label: _styledHeader('Team')),
      ],
      rows: matches.map((match) {
        int idx = matches.indexOf(match);
        return DataRow(
            color: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
              if (idx.isEven) return Theme.of(context).splashColor; // Color for even rows
              return Theme.of(context).secondaryHeaderColor; // Color for odd rows
            }),
            cells: [
              DataCell(
                Checkbox(
                  value: match.isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      match.isChecked = value!;
                    });
                  },
                ),
              ),
              DataCell(Text(match.matchNumber)),
              DataCell(Text(match.startTime)),
              DataCell(Text(match.firstTable)),
              DataCell(Text(match.firstTableTeam)),
              DataCell(Text(match.secondTable)),
              DataCell(Text(match.secondTableTeam)),
            ]);
      }).toList(),
    );
  }
}
