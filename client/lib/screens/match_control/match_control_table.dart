import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/network/network.dart';
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
  final Function(List<GameMatch> selectedMatches) onSelected;
  final String? loadedMatch;
  const MatchControlTable({Key? key, required this.con, required this.onSelected, required this.loadedMatch}) : super(key: key);

  @override
  _MatchControlTableState createState() => _MatchControlTableState();
}

class _MatchControlTableState extends State<MatchControlTable> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  List<MatchRow> _matches = [];
  final List<GameMatch> _selectedMatches = [];
  bool _multiMatch = false;

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
      _matches = m;
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
    // check if a match with the same table is already checked
    bool isSelectable = true;
    isSelectable = _selectedMatches.map((e) => e.onTableFirst.table).contains(matchRow.match.onTableFirst.table) ? false : isSelectable;
    isSelectable = _selectedMatches.map((e) => e.onTableSecond.table).contains(matchRow.match.onTableSecond.table) ? false : isSelectable;
    isSelectable = matchRow.isChecked ? true : isSelectable;
    return DataRow2(
      onTap: () {
        if (!_multiMatch) {
          widget.onSelected([matchRow.match]);
        }
      },
      color: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (index.isEven) return Theme.of(context).splashColor; // Color for even rows
        return Theme.of(context).colorScheme.secondary.withOpacity(0.1);
      }),
      cells: [
        if (_multiMatch && isSelectable)
          DataCell(
            Checkbox(
              value: matchRow.isChecked,
              onChanged: (bool? value) {
                setState(() {
                  matchRow.isChecked = value!;
                  if (value) {
                    _selectedMatches.add(matchRow.match);
                  } else {
                    _selectedMatches.remove(matchRow.match);
                  }
                  widget.onSelected(_selectedMatches);
                });
              },
            ),
          ),
        if (_multiMatch && !isSelectable) const DataCell(SizedBox()),
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
      int idx = _matches.indexWhere((m) => m.match.matchNumber == match.matchNumber);
      if (idx != -1) {
        setState(() {
          _matches[idx].match = match;
        });
      }
    });

    Future.delayed(const Duration(seconds: 1), () async {
      if (!await Network.isConnected()) {
        getMatches().then((matches) => setMatches(matches));
      }
    });
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
                    groupValue: _multiMatch,
                    onChanged: (bool? value) {
                      if (value != null) {
                        for (var match in _matches) {
                          match.isChecked = false;
                        }

                        setState(() {
                          _multiMatch = value;
                          _selectedMatches.clear();
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
                    groupValue: _multiMatch,
                    onChanged: (bool? value) {
                      if (value != null) {
                        setState(() {
                          _multiMatch = value;
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
              if (_multiMatch) DataColumn2(label: _styledHeader(''), size: ColumnSize.S),
              DataColumn2(label: _styledHeader('Match'), size: ColumnSize.S),
              DataColumn2(label: _styledHeader('Time')),
              DataColumn2(label: _styledHeader('Table')),
              DataColumn2(label: _styledHeader('Team')),
              DataColumn2(label: _styledHeader('Table')),
              DataColumn2(label: _styledHeader('Team')),
            ],
            // rows: ,
            rows: _matches.map((match) {
              int idx = _matches.indexOf(match);
              return _styledRow(match, idx);
            }).toList(),
          ),
        ),
      ],
    );
  }
}
