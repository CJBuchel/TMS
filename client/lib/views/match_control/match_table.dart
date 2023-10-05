import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/schema/tms_schema.dart';

class MatchTable extends StatefulWidget {
  final BoxConstraints con;
  final Event? event;
  final List<GameMatch> matches;
  final List<GameMatch> selectedMatches;
  final Function(List<GameMatch> selectedMatches) onSelected;
  final List<GameMatch> loadedMatches;

  const MatchTable({
    Key? key,
    required this.con,
    required this.event,
    required this.matches,
    required this.selectedMatches,
    required this.onSelected,
    required this.loadedMatches,
  }) : super(key: key);

  @override
  State<MatchTable> createState() => _MatchTableState();
}

class _MatchTableState extends State<MatchTable> {
  bool _multiMatch = false;

  void setMultiMatch(bool value) {
    if (mounted) {
      setState(() {
        _multiMatch = value;
        widget.onSelected([]);
      });
    }
  }

  void setSelected(GameMatch match) {
    if (mounted) {
      setState(() {
        widget.onSelected([match]);
      });
    }
  }

  Widget _radioButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Radio<bool>(
              value: false,
              groupValue: _multiMatch,
              onChanged: (bool? value) {
                if (value != null) {
                  setMultiMatch(value);
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
                  setMultiMatch(value);
                }
              },
            ),
            const Text("Multi Match"),
          ],
        )
      ],
    );
  }

  Widget _styledTextCell(String text, {Color? color, bool? deferred}) {
    Widget child = Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // strike through if deferred
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

    return Center(child: child);
  }

  Widget _styledRow(GameMatch match, int idx) {
    bool isLoaded = widget.loadedMatches.map((e) => e.matchNumber).contains(match.matchNumber) ? true : false;
    bool isDeferred = match.gameMatchDeferred;
    bool isSelected = widget.selectedMatches.map((e) => e.matchNumber).contains(match.matchNumber) ? true : false;
    bool isSelectable = true; // default

    // check if match with the same table is already checked (only useful during multimatch)
    for (var selectedMatch in widget.selectedMatches) {
      for (var selectedOnTable in selectedMatch.matchTables) {
        for (var onTable in match.matchTables) {
          if (selectedOnTable.table == onTable.table) {
            isSelectable = false;
          }
        }
      }
    }

    // check if match is already selected
    isSelectable = isSelected ? true : isSelectable;
    // check if match is loaded
    isSelectable = isLoaded ? false : isSelectable;

    Color? rowColor;
    if (isLoaded) {
      rowColor = Colors.orange;
    } else if (isSelected) {
      rowColor = Colors.blue[300];
    } else if (idx.isEven) {
      if (match.complete) {
        rowColor = Colors.green;
      } else {
        rowColor = Theme.of(context).splashColor;
      }
    } else {
      if (match.complete) {
        rowColor = Colors.green[300];
      } else {
        rowColor = Theme.of(context).colorScheme.secondary.withOpacity(0.1);
      }
    }

    Widget checkbox;

    if (isSelectable) {
      checkbox = Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Checkbox(
          value: isSelected,
          onChanged: (bool? value) {
            if (value != null) {
              if (value) {
                widget.onSelected([...widget.selectedMatches, match]);
              } else {
                widget.onSelected(widget.selectedMatches.where((element) => element.matchNumber != match.matchNumber).toList());
              }
            }
          },
        ),
      );
    } else {
      checkbox = const SizedBox.shrink();
    }

    return InkWell(
      onTap: () {
        if (!_multiMatch && widget.loadedMatches.isEmpty) {
          setSelected(match);
        }
      },
      child: Container(
        height: 50, // default row size
        width: widget.con.maxWidth, // expand as much as possible
        decoration: BoxDecoration(color: rowColor),
        child: Row(
          children: [
            // checkbox
            if (_multiMatch) Expanded(flex: 60, child: checkbox),

            // match number
            Expanded(
              flex: 60,
              child: _styledTextCell(match.matchNumber, deferred: isDeferred),
            ),

            // start time
            Expanded(
              flex: 100,
              child: _styledTextCell(match.startTime, deferred: isDeferred),
            ),

            ...match.matchTables.expand(
              (table) {
                return [
                  // table cell
                  Expanded(
                    flex: 100,
                    child: _styledTextCell(
                      table.table,
                      color: match.complete && !table.scoreSubmitted
                          ? Colors.red
                          : table.scoreSubmitted
                              ? Colors.green
                              : null,
                      deferred: isDeferred,
                    ),
                  ),

                  // team cell
                  Expanded(
                    flex: 60,
                    child: _styledTextCell(
                      table.teamNumber,
                      color: match.complete && !table.scoreSubmitted
                          ? Colors.red
                          : table.scoreSubmitted
                              ? Colors.green
                              : null,
                      deferred: isDeferred,
                    ),
                  ),
                ];
              },
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _table() {
    if (widget.matches.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      // create list view of match rows
      return ListView(
        children: widget.matches.map((match) {
          int idx = widget.matches.indexOf(match);
          return _styledRow(match, idx);
        }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double radioHeight = 50;
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
            height: radioHeight,
            child: _radioButtons(),
          ),

          // Table
          SizedBox(
            height: widget.con.maxHeight - radioHeight,
            child: _table(),
          )
        ],
      );
    }
  }
}
