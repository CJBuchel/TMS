import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
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
  final BoxConstraints con;
  const MatchControlTable({Key? key, required this.con}) : super(key: key);

  @override
  _MatchControlTableState createState() => _MatchControlTableState();
}

class _MatchControlTableState extends State<MatchControlTable> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  List<MatchRow> matches = [];
  bool multiMatch = false;

  void setMatches(List<GameMatch> gameMatches) async {
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

  DataCell _styledCell(String context) {
    return DataCell(
      Text(
        context,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  DataRow2 _styledRow(MatchRow match, int index) {
    return DataRow2(
      onTap: () {
        Logger().i("Selected: ${match.matchNumber}");
      },
      color: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (index.isEven) return Theme.of(context).splashColor; // Color for even rows
        return Theme.of(context).colorScheme.secondary.withOpacity(0.1);
      }),
      cells: [
        if (multiMatch)
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
        _styledCell(match.matchNumber),
        _styledCell(match.startTime),
        _styledCell(match.firstTable),
        _styledCell(match.firstTableTeam),
        _styledCell(match.secondTable),
        _styledCell(match.secondTableTeam),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    onMatchesUpdate((matches) {
      Logger().i("Match Update");
      setMatches(matches);
    });

    onMatchUpdate((match) {
      // find match number in current match array
      int idx = matches.indexWhere((m) => m.matchNumber == match.matchNumber);
      if (idx != -1) {
        setState(() {
          matches[idx].startTime = match.startTime;
          matches[idx].firstTable = match.onTableFirst.table;
          matches[idx].firstTableTeam = match.onTableFirst.teamNumber;
          matches[idx].secondTable = match.onTableSecond.table;
          matches[idx].secondTableTeam = match.onTableSecond.teamNumber;
        });
      }
    });
    getMatches().then((matches) => setMatches(matches));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Radio Buttons
        Container(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Radio<bool>(
                    value: false,
                    groupValue: multiMatch,
                    onChanged: (bool? value) {
                      if (value != null) {
                        setState(() {
                          multiMatch = value;
                        });
                      }
                    },
                  ),
                  const Text("Single Match"),
                ],
              ),
              Row(
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: multiMatch,
                    onChanged: (bool? value) {
                      if (value != null) {
                        setState(() {
                          multiMatch = value;
                        });
                      }
                    },
                  ),
                  const Text("Multi Match"),
                ],
              )
            ],
          ),
        ),
        Container(
          height: widget.con.maxHeight - 50,
          child: DataTable2(
            headingRowColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
              return Colors.transparent; // Color for header row
            }),
            columnSpacing: 10,
            columns: [
              if (multiMatch) DataColumn2(label: _styledHeader(''), size: ColumnSize.S),
              DataColumn2(label: _styledHeader('Match'), size: ColumnSize.S),
              DataColumn2(label: _styledHeader('Time')),
              DataColumn2(label: _styledHeader('Table')),
              DataColumn2(label: _styledHeader('Team')),
              DataColumn2(label: _styledHeader('Table')),
              DataColumn2(label: _styledHeader('Team')),
            ],
            rows: matches.map((match) {
              int idx = matches.indexOf(match);
              return _styledRow(match, idx);
            }).toList(),
          ),
        )
      ],
    );
  }
}
