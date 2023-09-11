import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
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
  final List<GameMatch> matches;
  final Function(List<GameMatch> selectedMatches) onSelected;
  final String? loadedMatch;
  const MatchControlTable({
    Key? key,
    required this.con,
    required this.matches,
    required this.onSelected,
    required this.loadedMatch,
  }) : super(key: key);

  @override
  _MatchControlTableState createState() => _MatchControlTableState();
}

class _MatchControlTableState extends State<MatchControlTable> {
  List<MatchRow> _matchRows = [];
  final List<GameMatch> _selectedMatches = [];
  bool _multiMatch = false;

  Widget _styledHeader(String content) {
    return Text(content, style: const TextStyle(fontWeight: FontWeight.bold));
  }

  DataCell _styledCell(String context, Color? color) {
    return DataCell(
      Container(
        color: color ?? Colors.transparent,
        child: Center(
          child: Text(
            context,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      showEditIcon: false,
      placeholder: false,
    );
  }

  DataRow2 _styledRow(MatchRow matchRow, int index) {
    // check if a match with the same table is already checked
    bool isSelectable = true;
    isSelectable = _selectedMatches.map((e) => e.onTableFirst.table).contains(matchRow.match.onTableFirst.table) ? false : isSelectable;
    isSelectable = _selectedMatches.map((e) => e.onTableSecond.table).contains(matchRow.match.onTableSecond.table) ? false : isSelectable;
    isSelectable = matchRow.isChecked ? true : isSelectable;

    // check if this match is currently selected
    bool isSelected = _selectedMatches.map((e) => e.matchNumber).contains(matchRow.match.matchNumber) ? true : false;

    return DataRow2(
      onTap: () {
        if (!_multiMatch) {
          setState(() {
            _selectedMatches.clear();
            _selectedMatches.add(matchRow.match);
            widget.onSelected(_selectedMatches);
          });
        }
      },
      color: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (isSelected) return Colors.blue[300] ?? Colors.blue;
        if (index.isEven) return matchRow.match.complete ? Colors.green : Theme.of(context).splashColor; // Color for even rows
        return matchRow.match.complete ? Colors.green[300] ?? Colors.green : Theme.of(context).colorScheme.secondary.withOpacity(0.1);
      }),
      cells: [
        if (_multiMatch && isSelectable)
          DataCell(
            Checkbox(
              value: matchRow.isChecked,
              checkColor: Colors.white,
              activeColor: Colors.blue[900],
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
        _styledCell(matchRow.match.matchNumber, null),
        _styledCell(matchRow.match.startTime, null),
        _styledCell(
          matchRow.match.onTableFirst.table,
          matchRow.match.complete && !matchRow.match.onTableFirst.scoreSubmitted ? Colors.red : null,
        ),
        _styledCell(
          matchRow.match.onTableFirst.teamNumber,
          matchRow.match.complete && !matchRow.match.onTableFirst.scoreSubmitted ? Colors.red : null,
        ),
        _styledCell(
          matchRow.match.onTableSecond.table,
          matchRow.match.complete && !matchRow.match.onTableSecond.scoreSubmitted ? Colors.red : null,
        ),
        _styledCell(
          matchRow.match.onTableSecond.teamNumber,
          matchRow.match.complete && !matchRow.match.onTableSecond.scoreSubmitted ? Colors.red : null,
        ),
      ],
    );
  }

  Widget getTable() {
    if (_matchRows.isEmpty) {
      // circular loader
      return const Center(
        child: CircularProgressIndicator(),
      );
      // return const Center(child: Text("No Matches", style: TextStyle(fontSize: 45)));
    } else {
      return DataTable2(
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
        rows: _matchRows.map((match) {
          int idx = _matchRows.indexOf(match);
          return _styledRow(match, idx);
        }).toList(),
      );
    }
  }

  @override
  void didUpdateWidget(covariant MatchControlTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.matches != widget.matches) {
      setState(() {
        _matchRows = widget.matches.map((e) => MatchRow(match: e, isChecked: false)).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _matchRows = widget.matches.map((e) => MatchRow(match: e, isChecked: false)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Radio Buttons
        SizedBox(
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
                        for (var match in _matchRows) {
                          match.isChecked = false;
                        }

                        setState(() {
                          _multiMatch = value;
                          _selectedMatches.clear();
                          widget.onSelected([]);
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
                          _selectedMatches.clear();
                          widget.onSelected([]);
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
        SizedBox(
          height: widget.con.maxHeight - 50,
          child: getTable(),
        ),
      ],
    );
  }
}
