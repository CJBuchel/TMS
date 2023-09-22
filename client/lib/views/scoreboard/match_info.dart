import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/scoreboard/match_loaded_table.dart';
import 'package:tms/views/timer/clock.dart';

enum MatchInfoState {
  none, // display nothing
  info, // display basic match info
  loadedInfo, // display match info for loaded match
}

class MatchInfo extends StatefulWidget {
  final bool alwaysMatchInfo;
  final double? height;
  const MatchInfo({Key? key, required this.alwaysMatchInfo, this.height}) : super(key: key);

  @override
  State<MatchInfo> createState() => _MatchInfoState();
}

class _MatchInfoState extends State<MatchInfo> with AutoUnsubScribeMixin {
  MatchInfoState _currentState = MatchInfoState.none;

  List<Team> _loadedFirstTeams = []; // first set of tables
  List<Team> _loadedSecondTeams = []; // second set of tables

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
          setState(() {
            _currentState = MatchInfoState.loadedInfo;
          });
        }
      } else if (m.subTopic == "unload") {
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

  Widget getLoadedInfo(double height) {
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
                      child: const Center(child: Text("Event Name")),
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
                      child: const Center(child: Text("Match: ")),
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
                      child: MatchLoadedTable(teams: _loadedFirstTeams),
                    ),

                    // timer
                    Container(
                      color: Colors.white,
                      height: constraints.maxHeight,
                      width: (constraints.maxWidth / 100) * 20,
                      child: const Center(child: Clock(fontSize: 70)),
                    ),

                    // on second tables
                    Container(
                      color: const Color.fromARGB(255, 218, 218, 218),
                      width: (constraints.maxWidth / 100) * 40,
                      child: MatchLoadedTable(teams: _loadedSecondTeams),
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
    return getLoadedInfo(widget.height ?? 190);
    // if (_currentState == MatchInfoState.info) {
    //   return const Text("Info");
    // } else if (_currentState == MatchInfoState.loadedInfo) {
    //   return getLoadedInfo();
    // } else {
    //   return const SizedBox();
    // }
  }
}
