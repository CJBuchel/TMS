import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/schema/tms_schema.dart';

class MatchRow {
  GameMatch match;
  bool isChecked;
  MatchRow({
    required this.match,
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
          match: match,
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

  DataRow2 _styledRow(MatchRow matchRow, int index) {
    return DataRow2(
      onTap: () {
        Logger().i("Selected: ${matchRow.match.matchNumber}");
      },
      color: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (index.isEven) return Theme.of(context).splashColor; // Color for even rows
        return Theme.of(context).colorScheme.secondary.withOpacity(0.1);
      }),
      cells: [
        if (multiMatch)
          DataCell(
            Checkbox(
              value: matchRow.isChecked,
              onChanged: (bool? value) {
                setState(() {
                  matchRow.isChecked = value!;
                });
              },
            ),
          ),
        _styledCell(matchRow.match.matchNumber),
        _styledCell(matchRow.match.startTime),
        _styledCell(matchRow.match.onTableFirst.table),
        _styledCell(matchRow.match.onTableFirst.teamNumber),
        _styledCell(matchRow.match.onTableSecond.table),
        _styledCell(matchRow.match.onTableSecond.teamNumber),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    onMatchesUpdate((matches) {
      setMatches(matches);
    });

    onMatchUpdate((match) {
      // find match number in current match array
      int idx = matches.indexWhere((m) => m.match.matchNumber == match.matchNumber);
      if (idx != -1) {
        setState(() {
          matches[idx].match = match;
        });
      }
    });
    // getMatches().then((matches) => setMatches(matches));
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
            // rows: ,
            rows: matches.map((match) {
              int idx = matches.indexOf(match);
              return _styledRow(match, idx);
            }).toList(),
          ),
        ),
      ],
    );
  }
}
