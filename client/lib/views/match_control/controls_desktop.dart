import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/match_control/controls_shared.dart';
import 'package:tms/views/match_control/match_status.dart';
import 'package:tms/views/match_control/staging_table.dart';
import 'package:tms/views/match_control/timer_control.dart';
import 'package:tms/views/match_control/ttl_clock.dart';
import 'package:tms/views/timer/clock.dart';

class MatchControlDesktopControls extends StatelessWidget {
  final BoxConstraints con;
  final List<Team> teams;
  final List<GameMatch> matches;
  final List<GameMatch> loadedMatches;
  final List<GameMatch> selectedMatches;

  // constructor
  const MatchControlDesktopControls({
    Key? key,
    required this.con,
    required this.teams,
    required this.selectedMatches,
    required this.matches,
    required this.loadedMatches,
  }) : super(key: key);

  final double desktopButtonHeight = 40;
  final double tabletButtonHeight = 24;
  final double desktopButtonTextSize = 18;
  final double tabletButtonTextSize = 14;

  getControls(double maxHeight, BuildContext context) {
    bool isLoadable = selectedMatches.isNotEmpty && loadedMatches.isEmpty && selectedMatches.every((element) => !element.complete);

    for (var selectedMatch in selectedMatches) {
      // find any previous matches that are complete and tables that have not submitted their scores
      for (var previousMatch in matches.where((element) => element.complete)) {
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
    isLoadable = selectedMatches.every((element) => element.gameMatchDeferred) ? false : isLoadable;
    bool isDeferrable = selectedMatches.every((element) => element.gameMatchDeferred) ? true : isLoadable;
    bool isIncomplete = isLoadable;
    bool isUnloadable = loadedMatches.isNotEmpty;
    bool isComplete = selectedMatches.isNotEmpty && loadedMatches.isEmpty && selectedMatches.every((element) => element.complete);
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
                            loadMatch(MatchLoadStatus.load, context, selectedMatches).then((value) {
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
                            loadMatch(MatchLoadStatus.unload, context, loadedMatches).then((value) {
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
                child: TTLClock(matches: matches),
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
                  MatchStatus(isLoaded: loadedMatches.isNotEmpty),

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
                                  updateMatch(MatchUpdateStatus.incomplete, context, selectedMatches).then((value) {
                                    if (value != HttpStatus.ok) {
                                      displayErrorDialog(value, context);
                                    }
                                  });
                                  selectedMatches.clear();
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
                                  updateMatch(MatchUpdateStatus.complete, context, selectedMatches).then((value) {
                                    if (value != HttpStatus.ok) {
                                      displayErrorDialog(value, context);
                                    }
                                  });
                                  selectedMatches.clear();
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
                            if (selectedMatches.every((element) => element.gameMatchDeferred)) {
                              updateMatch(MatchUpdateStatus.expedite, context, selectedMatches).then((value) {
                                if (value != HttpStatus.ok) {
                                  displayErrorDialog(value, context);
                                }
                              });
                            } else {
                              updateMatch(MatchUpdateStatus.defer, context, selectedMatches).then((value) {
                                if (value != HttpStatus.ok) {
                                  displayErrorDialog(value, context);
                                }
                              });
                            }
                          }
                        },
                        icon: Icon(Icons.hourglass_empty, size: Responsive.isDesktop(context) ? desktopButtonTextSize : tabletButtonTextSize),
                        label: Text(
                            selectedMatches.every((element) {
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Clock(fontSize: Responsive.isDesktop(context) ? 90 : 70),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TimerControl(
                    loadedMatches: loadedMatches,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  build(BuildContext context) {
    double controlMaxHeight = (con.maxHeight / 3) * 2; // 2/3 of the screen
    return Column(
      children: [
        SizedBox(
          height: con.maxHeight / 3, // 1/3 of the screen
          child: StagingTable(
            teams: teams,
            loadedMatches: loadedMatches,
            selectedMatches: selectedMatches,
          ),
        ),
        SizedBox(
          height: controlMaxHeight,
          child: getControls(controlMaxHeight, context),
        )
      ],
    );
  }
}
