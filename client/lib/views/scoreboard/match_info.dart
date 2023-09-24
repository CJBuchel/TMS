import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/scoreboard/match_loaded_table.dart';
import 'package:tms/views/shared/sorter_util.dart';
import 'package:tms/views/timer/clock.dart';

enum MatchInfoState {
  none, // display nothing
  info, // display basic match info
  loadedInfo, // display match info for loaded match
}

class MatchInfo extends StatefulWidget {
  final bool alwaysMatchInfo;
  final List<Team> teams;
  final List<GameMatch> matches;
  final double? height;
  const MatchInfo({Key? key, required this.alwaysMatchInfo, required this.teams, required this.matches, this.height}) : super(key: key);

  @override
  State<MatchInfo> createState() => _MatchInfoState();
}

class _MatchInfoState extends State<MatchInfo> with AutoUnsubScribeMixin {
  MatchInfoState _currentState = MatchInfoState.none;

  List<OnTable> _loadedFirstTables = []; // first set of tables
  List<OnTable> _loadedSecondTables = []; // second set of tables
  List<GameMatch> _loadedMatches = [];

  void setLoadedInfo(List<GameMatch> matches) {
    // set first set of tables
    List<OnTable> loadedFirst = [];
    List<OnTable> loadedSecond = [];
    for (var match in matches) {
      loadedFirst.add(match.onTableFirst);
      loadedSecond.add(match.onTableSecond);
    }

    setState(() {
      _loadedFirstTables = loadedFirst;
      _loadedSecondTables = loadedSecond;
      _loadedMatches = matches;
    });
  }

  @override
  void didUpdateWidget(covariant MatchInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      if (widget.alwaysMatchInfo) {
        _currentState = MatchInfoState.info;
      } else {
        _currentState = MatchInfoState.none;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.alwaysMatchInfo) {
      _currentState = MatchInfoState.info;
    }

    // match info
    autoSubscribe("match", (m) {
      if (m.subTopic == "load") {
        if (m.message.isNotEmpty) {
          // on load

          final jsonString = jsonDecode(m.message);
          SocketMatchLoadedMessage message = SocketMatchLoadedMessage.fromJson(jsonString);

          List<GameMatch> loadedMatches = [];
          for (var loadedMatchNumber in message.matchNumbers) {
            for (var match in widget.matches) {
              if (match.matchNumber == loadedMatchNumber) {
                loadedMatches.add(match);
              }
            }
          }

          setLoadedInfo(loadedMatches);

          setState(() {
            _currentState = MatchInfoState.loadedInfo;
          });
        }
      } else if (m.subTopic == "unload") {
        setState(() {
          _loadedFirstTables = [];
          _loadedSecondTables = [];
        });
        // on unload
        if (widget.alwaysMatchInfo) {
          setState(() {
            _currentState = MatchInfoState.info;
          });
        } else {
          setState(() {
            _currentState = MatchInfoState.none;
          });
        }
      }
    });
  }

  String getScheduledMatchTime() {
    if (_loadedMatches.isNotEmpty) {
      return sortMatchesByTime(_loadedMatches).first.startTime.toString();
    } else {
      return "No Match Time";
    }
  }

  String getLoadedMatches() {
    if (_loadedMatches.isNotEmpty) {
      return _loadedMatches.map((e) => e.matchNumber.toString()).join(", ");
    } else {
      return "No Matches Loaded";
    }
  }

  Widget getLoadedInfo(double height) {
    double fontSize = Responsive.isDesktop(context)
        ? 20
        : Responsive.isTablet(context)
            ? 10
            : 8;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: height,
          width: constraints.maxWidth,
          child: Column(
            children: [
              // header row

              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    // match status and event name
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xff4FC3A1),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                          top: BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                      ),
                      // color: const Color(0xff4FC3A1),
                      width: (constraints.maxWidth / 100) * 60,
                      child: Center(child: Text("Next Match: ${getScheduledMatchTime()}", style: TextStyle(fontSize: fontSize))),
                    ),

                    // match numbers
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xff324960),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                          top: BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                      ),
                      width: (constraints.maxWidth / 100) * 40,
                      child: Center(child: Text("Match: ${getLoadedMatches()}", style: TextStyle(fontSize: fontSize))),
                    )
                  ],
                ),
              ),

              Expanded(
                child: Row(
                  children: [
                    // on first tables
                    Container(
                      color: const Color.fromARGB(255, 218, 218, 218),
                      width: (constraints.maxWidth / 100) * 40,
                      child: MatchLoadedTable(teams: widget.teams, tables: _loadedFirstTables),
                    ),

                    // timer
                    Container(
                      color: Colors.white,
                      height: constraints.maxHeight,
                      width: (constraints.maxWidth / 100) * 20,
                      child: const Center(child: Clock(fontSize: 70, overrideFontColor: Colors.black)),
                    ),

                    // on second tables
                    Container(
                      color: const Color.fromARGB(255, 218, 218, 218),
                      width: (constraints.maxWidth / 100) * 40,
                      child: MatchLoadedTable(teams: widget.teams, tables: _loadedSecondTables),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // return getLoadedInfo(widget.height ?? 160);
    if (_currentState == MatchInfoState.info) {
      return const Text("Info");
    } else if (_currentState == MatchInfoState.loadedInfo) {
      return getLoadedInfo(widget.height ?? 160);
    } else {
      return const SizedBox();
    }
  }
}
