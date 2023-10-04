import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/schema/tms_schema.dart';

class MatchControlTable extends StatefulWidget {
  final BoxConstraints con;
  final Event? event;
  final List<GameMatch> matches;
  final List<GameMatch> selectedMatches;
  final Function(List<GameMatch> selectedMatches) onSelected;
  final List<GameMatch> loadedMatches;
  const MatchControlTable({
    Key? key,
    required this.con,
    required this.event,
    required this.matches,
    required this.selectedMatches,
    required this.onSelected,
    required this.loadedMatches,
  }) : super(key: key);

  @override
  State<MatchControlTable> createState() => _MatchControlTableState();
}

class _MatchControlTableState extends State<MatchControlTable> {
  bool _multiMatch = false;

  Widget _styledHeader(String content) {
    return Center(child: Text(content, style: const TextStyle(fontWeight: FontWeight.bold)));
  }

  DataCell _styledCell(String context, {Color? color, bool? deferred}) {
    Widget child = Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            context,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (deferred ?? false)
          Align(
            alignment: Alignment.center,
            child: Divider(
              color: AppTheme.isDarkTheme ? Colors.white : Colors.black,
              thickness: 2,
            ),
          ),
      ],
    );

    return DataCell(
      Container(
        color: color ?? Colors.transparent,
        child: Center(child: child),
      ),
      showEditIcon: false,
      placeholder: false,
    );
  }

  DataRow2 _styledRow(GameMatch match, int index) {
    // check if this match is loaded
    bool isLoaded = widget.loadedMatches.map((e) => e.matchNumber).contains(match.matchNumber) ? true : false;

    // check if this match is deferred
    bool isDeferred = match.gameMatchDeferred;

    // check if this match is currently selected
    bool isSelected = widget.selectedMatches.map((e) => e.matchNumber).contains(match.matchNumber) ? true : false;

    // check if a match with the same table is already checked
    bool isSelectable = true;
    for (var selectedMatch in widget.selectedMatches) {
      for (var onTable in selectedMatch.matchTables) {
        for (var onThisTable in match.matchTables) {
          if (onTable.table == onThisTable.table) {
            isSelectable = false;
          }
        }
      }
    }
    isSelectable = isSelected ? true : isSelectable;
    isSelectable = widget.loadedMatches.isNotEmpty ? false : isSelectable;

    return DataRow2(
      onTap: () {
        if (!_multiMatch && widget.loadedMatches.isEmpty) {
          setState(() {
            List<GameMatch> m = [match];
            widget.onSelected(m);
          });
        }
      },
      color: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (isLoaded) return Colors.orange;
        if (isSelected) return Colors.blue[300] ?? Colors.blue;
        if (index.isEven) return match.complete ? Colors.green : Theme.of(context).splashColor; // Color for even rows
        return match.complete ? Colors.green : Theme.of(context).colorScheme.secondary.withOpacity(0.1);
      }),
      cells: [
        if (_multiMatch && isSelectable)
          DataCell(
            Checkbox(
              value: isSelected,
              checkColor: Colors.white,
              activeColor: Colors.blue[900],
              onChanged: (bool? value) {
                setState(() {
                  List<GameMatch> m = [...widget.selectedMatches];
                  if (value!) {
                    m.add(match);
                  } else {
                    m.remove(match);
                  }
                  widget.onSelected(m);
                });
              },
            ),
          ),
        if (_multiMatch && !isSelectable) const DataCell(SizedBox()),
        _styledCell(match.matchNumber, deferred: isDeferred),
        _styledCell(match.startTime, deferred: isDeferred),

        // generate cells for each table
        ...match.matchTables.expand((table) {
          return [
            // table cell
            _styledCell(
              table.table,
              color: match.complete && !table.scoreSubmitted
                  ? Colors.red
                  : !match.complete
                      ? Colors.green
                      : null,
              deferred: isDeferred,
            ),

            // team cell
            _styledCell(
              table.teamNumber,
              color: match.complete && !table.scoreSubmitted
                  ? Colors.red
                  : !match.complete
                      ? Colors.green
                      : null,
              deferred: isDeferred,
            ),
          ];
        }),
      ],
    );
  }

  Widget getTable() {
    if (widget.matches.isEmpty) {
      // circular loader
      return const Center(
        child: CircularProgressIndicator(),
      );
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
          ...List.generate((widget.event?.tables.length ?? 0) * 2, (index) => const DataColumn2(label: SizedBox.shrink())),
        ],
        rows: widget.matches.map((match) {
          int idx = widget.matches.indexOf(match);
          return _styledRow(match, idx);
        }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.event?.tables.isEmpty ?? true) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
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
                          setState(() {
                            _multiMatch = value;
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
}
