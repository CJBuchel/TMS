import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/screens/match_control/controls_shared.dart';
import 'package:tms/screens/match_control/match_status.dart';
import 'package:tms/screens/match_control/timer_control.dart';
import 'package:tms/screens/match_control/ttl_clock.dart';
import 'package:tms/screens/timer/clock.dart';

class MatchControlControls extends StatefulWidget {
  final BoxConstraints con;
  final List<Team> teams;
  final List<GameMatch> matches;
  final List<GameMatch> loadedMatches;
  final List<GameMatch> selectedMatches;
  const MatchControlControls({
    Key? key,
    required this.con,
    required this.teams,
    required this.selectedMatches,
    required this.matches,
    required this.loadedMatches,
  }) : super(key: key);

  @override
  _MatchControlControlsState createState() => _MatchControlControlsState();
}

class _MatchControlControlsState extends State<MatchControlControls> with SingleTickerProviderStateMixin, AutoUnsubScribeMixin {
  late AnimationController _controller;
  double desktopButtonHeight = 40;
  double tabletButtonHeight = 24;
  double desktopButtonTextSize = 18;
  double tabletButtonTextSize = 14;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget getControls(double maxHeight) {
    bool isLoadable =
        widget.selectedMatches.isNotEmpty && widget.loadedMatches.isEmpty && widget.selectedMatches.every((element) => !element.complete);

    for (var selectedMatch in widget.selectedMatches) {
      // find any previous matches that are complete and tables that have not submitted their scores
      for (var previousMatch in widget.matches.where((element) => element.complete)) {
        if (previousMatch.onTableFirst.table == selectedMatch.onTableFirst.table) {
          if (!previousMatch.onTableFirst.scoreSubmitted) {
            Logger().i("Match ${previousMatch.matchNumber} on table ${previousMatch.onTableSecond.table} has not submitted scores");
            isLoadable = false;
          }
        }
        if (previousMatch.onTableSecond.table == selectedMatch.onTableSecond.table) {
          if (!previousMatch.onTableSecond.scoreSubmitted) {
            Logger().i("Match ${previousMatch.matchNumber} on table ${previousMatch.onTableSecond.table} has not submitted scores");
            isLoadable = false;
          }
        }
      }
    }
    bool isDeferrable = isLoadable;
    bool isIncomplete = isLoadable;
    bool isUnloadable = widget.loadedMatches.isNotEmpty;
    bool isComplete =
        widget.selectedMatches.isNotEmpty && widget.loadedMatches.isEmpty && widget.selectedMatches.every((element) => element.complete);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Load/Unload Buttons
          SizedBox(
            height: (maxHeight / 100) * 15, // 10%
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: Responsive.isDesktop(context) ? desktopButtonHeight : tabletButtonHeight,
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                          backgroundColor:
                              isLoadable ? MaterialStateProperty.all<Color>(Colors.orange) : MaterialStateProperty.all<Color>(Colors.grey),
                        ),
                        onPressed: () {
                          if (isLoadable) {
                            loadMatch(MatchLoadStatus.load, context, widget.selectedMatches).then((value) {
                              if (value != HttpStatus.ok) {
                                displayErrorDialog(value, context);
                              }
                            });
                          }
                        },
                        icon: Icon(Icons.arrow_downward, size: Responsive.isDesktop(context) ? desktopButtonTextSize : tabletButtonTextSize),
                        label: Text("Load", style: TextStyle(fontSize: Responsive.isDesktop(context) ? desktopButtonTextSize : tabletButtonTextSize)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // spacing
                  Expanded(
                    child: SizedBox(
                      height: Responsive.isDesktop(context) ? desktopButtonHeight : tabletButtonHeight,
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                          backgroundColor:
                              isUnloadable ? MaterialStateProperty.all<Color>(Colors.orange) : MaterialStateProperty.all<Color>(Colors.grey),
                        ),
                        onPressed: () {
                          if (isUnloadable) {
                            loadMatch(MatchLoadStatus.unload, context, widget.loadedMatches).then((value) {
                              if (value != HttpStatus.ok) {
                                displayErrorDialog(value, context);
                              }
                            });
                          }
                        },
                        icon: Icon(Icons.arrow_upward, size: Responsive.isDesktop(context) ? desktopButtonTextSize : tabletButtonTextSize),
                        label:
                            Text("Unload", style: TextStyle(fontSize: Responsive.isDesktop(context) ? desktopButtonTextSize : tabletButtonTextSize)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TTL Clock
          SizedBox(
            height: (maxHeight / 100) * 15, // 15%
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    width: 3.0,
                    color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                  ),
                  bottom: BorderSide(
                    width: 3.0,
                    color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                  ),
                ),
              ),
              child: Center(
                child: TTLClock(matches: widget.matches),
              ),
            ),
          ),

          // Status of Match
          SizedBox(
            height: (maxHeight / 100) * 35, // 30%
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 6, 0, 5),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 3.0,
                    color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MatchStatus(isLoaded: widget.loadedMatches.isNotEmpty),

                  // buttons for match setter
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: Responsive.isDesktop(context) ? desktopButtonHeight : tabletButtonHeight,
                            child: ElevatedButton.icon(
                              style: ButtonStyle(
                                backgroundColor:
                                    isComplete ? MaterialStateProperty.all<Color>(Colors.red) : MaterialStateProperty.all<Color>(Colors.grey),
                              ),
                              onPressed: () {
                                if (isComplete) {
                                  updateMatch(MatchUpdateStatus.incomplete, context, widget.selectedMatches).then((value) {
                                    if (value != HttpStatus.ok) {
                                      displayErrorDialog(value, context);
                                    }
                                  });
                                  widget.selectedMatches.clear();
                                }
                              },
                              icon: Icon(Icons.clear, size: Responsive.isDesktop(context) ? desktopButtonTextSize : tabletButtonTextSize),
                              label: Text("Set Match Incomplete",
                                  style: TextStyle(fontSize: Responsive.isDesktop(context) ? desktopButtonTextSize : tabletButtonTextSize)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16), // spacing
                        Expanded(
                          child: SizedBox(
                            height: Responsive.isDesktop(context) ? desktopButtonHeight : tabletButtonHeight,
                            child: ElevatedButton.icon(
                              style: ButtonStyle(
                                backgroundColor:
                                    isIncomplete ? MaterialStateProperty.all<Color>(Colors.green) : MaterialStateProperty.all<Color>(Colors.grey),
                              ),
                              onPressed: () {
                                if (isIncomplete) {
                                  updateMatch(MatchUpdateStatus.complete, context, widget.selectedMatches).then((value) {
                                    if (value != HttpStatus.ok) {
                                      displayErrorDialog(value, context);
                                    }
                                  });
                                  widget.selectedMatches.clear();
                                }
                              },
                              icon: Icon(Icons.check, size: Responsive.isDesktop(context) ? desktopButtonTextSize : tabletButtonTextSize),
                              label: Text("Set Match Complete",
                                  style: TextStyle(fontSize: Responsive.isDesktop(context) ? desktopButtonTextSize : tabletButtonTextSize)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: SizedBox(
                      height: Responsive.isDesktop(context) ? desktopButtonHeight : tabletButtonHeight,
                      width: Responsive.buttonWidth(context, 1),
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                          backgroundColor:
                              isDeferrable ? MaterialStateProperty.all<Color>(Colors.blue) : MaterialStateProperty.all<Color>(Colors.grey),
                        ),
                        onPressed: () {
                          if (isDeferrable) {
                            if (widget.selectedMatches.every((element) => element.gameMatchDeferred)) {
                              updateMatch(MatchUpdateStatus.expedite, context, widget.selectedMatches).then((value) {
                                if (value != HttpStatus.ok) {
                                  displayErrorDialog(value, context);
                                }
                              });
                            } else {
                              updateMatch(MatchUpdateStatus.defer, context, widget.selectedMatches).then((value) {
                                if (value != HttpStatus.ok) {
                                  displayErrorDialog(value, context);
                                }
                              });
                            }
                          }
                        },
                        icon: Icon(Icons.hourglass_empty, size: Responsive.isDesktop(context) ? desktopButtonTextSize : tabletButtonTextSize),
                        label: Text(
                            widget.selectedMatches.every((element) {
                              return element.gameMatchDeferred;
                            })
                                ? "Expedite Match"
                                : "Defer Match",
                            style: TextStyle(fontSize: Responsive.isDesktop(context) ? desktopButtonTextSize : tabletButtonTextSize)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Timer Controls
          SizedBox(
            height: (maxHeight / 100) * 35, // 40%
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 3.0,
                    color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Clock(fontSize: Responsive.isDesktop(context) ? 90 : 70),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TimerControl(
                      loadedMatches: widget.loadedMatches,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getStagingTable() {
    if (widget.selectedMatches.isEmpty && widget.loadedMatches.isEmpty) {
      return const Center(child: Text("No Matches Staged", style: TextStyle(fontSize: 45)));
    } else {
      return DataTable2(
        headingRowColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
          return Colors.transparent;
        }),
        columnSpacing: 10,
        columns: [
          DataColumn2(label: styledHeader("Match"), size: ColumnSize.S),
          DataColumn2(label: styledHeader("Table")),
          DataColumn2(label: styledHeader("Team")),
          DataColumn2(label: styledHeader("Name"), size: ColumnSize.L),
        ],
        rows: getRows(widget.selectedMatches, widget.loadedMatches, widget.teams, _controller),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double controlMaxHeight = (widget.con.maxHeight / 3) * 2; // 2/3 of the screen
    return Column(
      children: [
        SizedBox(
          height: widget.con.maxHeight / 3, // 1/3 of the screen
          child: getStagingTable(),
        ),
        SizedBox(
          height: controlMaxHeight,
          child: getControls(controlMaxHeight),
        )
      ],
    );
  }
}
