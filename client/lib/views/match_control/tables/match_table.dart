import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/value_listenables.dart';

class MatchTable extends StatelessWidget {
  final BoxConstraints con;
  final ValueNotifier<Event?> event;
  final ValueNotifier<List<GameMatch>> matches;
  final ValueNotifier<List<GameMatch>> selectedMatches;
  final ValueNotifier<List<GameMatch>> loadedMatches;
  final Function(List<GameMatch> selectedMatches) onSelected;

  MatchTable({
    Key? key,
    required this.con,
    required this.event,
    required this.matches,
    required this.selectedMatches,
    required this.onSelected,
    required this.loadedMatches,
  }) : super(key: key);

  final ValueNotifier<bool> _multiMatchNotifier = ValueNotifier<bool>(false);

  void setMultiMatch(bool value) {
    onSelected([]);
    _multiMatchNotifier.value = value;
  }

  void setSelected(GameMatch match) {
    onSelected([match]);
  }

  Widget _radioButtons() {
    return ValueListenableBuilder(
      valueListenable: _multiMatchNotifier,
      builder: (context, multiMatch, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Radio<bool>(
                  value: false,
                  groupValue: multiMatch,
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
                  groupValue: multiMatch,
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
      },
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

    return Container(
      color: color,
      child: Center(child: child),
    );
  }

  Widget _styledRow(BuildContext context, GameMatch match, int idx, List<GameMatch> loadedMatches, List<GameMatch> selectedMatches) {
    bool isLoaded = loadedMatches.map((e) => e.matchNumber).contains(match.matchNumber) ? true : false;
    bool isDeferred = match.gameMatchDeferred;
    bool isSelected = selectedMatches.map((e) => e.matchNumber).contains(match.matchNumber) ? true : false;
    bool isSelectable = true; // default

    // check if match with the same table is already checked (only useful during multimatch)
    for (var selectedMatch in selectedMatches) {
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
                onSelected([...selectedMatches, match]);
              } else {
                onSelected(selectedMatches.where((element) => element.matchNumber != match.matchNumber).toList());
              }
            }
          },
        ),
      );
    } else {
      checkbox = const SizedBox.shrink();
    }

    return ValueListenableBuilder(
      valueListenable: _multiMatchNotifier,
      builder: (context, multiMatch, _) {
        return InkWell(
          onTap: () {
            if (!multiMatch && loadedMatches.isEmpty) {
              setSelected(match);
            }
          },
          child: Container(
            height: 50, // default row size
            width: con.maxWidth, // expand as much as possible
            decoration: BoxDecoration(
              color: rowColor,
              border: const Border(
                bottom: BorderSide(
                  color: Colors.grey,
                ),
              ),
            ),
            child: Row(
              children: [
                // checkbox
                if (multiMatch) SizedBox(width: 50, child: checkbox),

                // match number
                SizedBox(
                  width: 50,
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
      },
    );
  }

  Widget _table(BuildContext context) {
    return ValueListenableBuilder3(
      first: matches,
      second: selectedMatches,
      third: loadedMatches,
      builder: (context, matches, selected, loaded, _) {
        if (matches.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          // create list view of match rows
          return ListView(
            children: matches.map((match) {
              int idx = matches.indexOf(match);
              return _styledRow(context, match, idx, loaded, selected);
            }).toList(),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double radioHeight = 50;

    return ValueListenableBuilder(
      valueListenable: event,
      builder: (context, Event? event, child) {
        if (event?.tables.isEmpty ?? true) {
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
                height: con.maxHeight - radioHeight,
                child: _table(context),
              )
            ],
          );
        }
      },
    );
  }
}
