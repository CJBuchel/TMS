import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/parse_util.dart';
import 'package:tms/views/shared/sorter_util.dart';

enum JudgeInfoState {
  none,
  info,
}

class JudgeInfo extends StatefulWidget {
  final bool alwaysJudgeSchedule;
  final List<JudgingSession> judgingSessions;
  final List<Team> teams;
  final Event? event;
  final double? height;
  const JudgeInfo({
    Key? key,
    required this.alwaysJudgeSchedule,
    required this.judgingSessions,
    required this.teams,
    required this.event,
    this.height,
  }) : super(key: key);

  @override
  State<JudgeInfo> createState() => _JudgeInfoState();
}

class _JudgeInfoState extends State<JudgeInfo> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  JudgeInfoState _currentState = JudgeInfoState.none;
  List<JudgingSession> _futureJudgingSessions = [];
  Timer? _timer;

  final double _mainCellWidth = 400;
  final int _scrollSpeed = 25;

  late ScrollController _scrollController;
  late AnimationController _animationController;

  bool _animationHasBeenInitialized = false;

  void initializeInfiniteAnimation() {
    if ((widget.event?.pods.isNotEmpty ?? false) && !_animationHasBeenInitialized) {
      _animationHasBeenInitialized = true;
      _animationController = AnimationController(
        vsync: this,
        duration: Duration(seconds: (widget.event?.pods.isEmpty ?? true ? 1 : widget.event!.pods.length) * _scrollSpeed),
      )
        ..addListener(() {
          double resetPosition = widget.event!.pods.length * _mainCellWidth; // Position where the second table starts
          double currentScroll = _animationController.value * resetPosition * 2; // Scrolling through double the data

          if (currentScroll >= resetPosition && _scrollController.hasClients && (widget.event?.pods.isNotEmpty ?? false)) {
            _animationController.forward(from: 0.0);
          } else {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(currentScroll);
            }
          }
        })
        ..repeat();
    }
  }

  void setFutureJudgingSessions() {
    List<JudgingSession> sessions = [];

    for (var session in widget.judgingSessions) {
      DateTime? endTime = parseStringTime(session.endTime);

      if (endTime != null) {
        if (endTime.isAfter(DateTime.now())) {
          sessions.add(session);
        }
      }
    }

    sessions = sortJudgingByTime(sessions);

    if (!listEquals(sessions, _futureJudgingSessions)) {
      setState(() {
        _futureJudgingSessions = sessions;
      });
    }
  }

  @override
  void didUpdateWidget(covariant JudgeInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      if (widget.event?.pods.length != oldWidget.event?.pods.length) {
        if (!_animationHasBeenInitialized) {
          initializeInfiniteAnimation();
        }
      }

      if (widget.alwaysJudgeSchedule) {
        _currentState = JudgeInfoState.info;
      } else {
        _currentState = JudgeInfoState.none;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    setFutureJudgingSessions();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setFutureJudgingSessions();
    });

    _scrollController = ScrollController();
    initializeInfiniteAnimation();

    if (widget.alwaysJudgeSchedule) {
      _currentState = JudgeInfoState.info;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    if (_animationHasBeenInitialized) {
      _animationController.dispose();
    }
    super.dispose();
  }

  Widget _buildCell(String text, {Color? backgroundColor, Color? textColor, double? width}) {
    return Container(
      width: width,
      color: backgroundColor,
      child: Center(child: Text(text, style: TextStyle(color: textColor, overflow: TextOverflow.ellipsis))),
    );
  }

  Widget _buildJudgingSubRow(List<Team> teams, JudgingPod pod) {
    // get team
    Team? team;
    for (var t in teams) {
      if (t.teamNumber == pod.teamNumber) {
        team = t;
        break;
      }
    }

    return SizedBox(
      width: _mainCellWidth,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          team != null ? "${team.teamNumber} | ${team.teamName} | ${pod.pod}" : "-",
          style: const TextStyle(color: Colors.black, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }

  Widget _buildRow(List<Team> teams, JudgingSession session, Color rowColor, double rowHeight, double rowWidth) {
    // first cell needs to be the time and is static
    double cellWidth = 300;
    return SizedBox(
      height: rowHeight,
      width: rowWidth,
      child: Row(
        children: [
          Container(
            child: _buildCell("${session.startTime} - ${session.endTime}", backgroundColor: rowColor, textColor: Colors.black, width: cellWidth),
          ),

          // check if infinite stripe is needed infinite stripe

          LayoutBuilder(
            builder: (context, constraints) {
              double availableWidth = rowWidth - cellWidth;
              if (availableWidth < session.judgingPods.length * _mainCellWidth) {
                // infinite table
                return Container(
                  color: rowColor,
                  width: rowWidth - cellWidth,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: session.judgingPods.length * 2,
                    itemBuilder: (context, index) {
                      return _buildJudgingSubRow(
                        teams,
                        session.judgingPods[index % session.judgingPods.length],
                      );
                    },
                  ),
                );
              } else {
                // static table
                return Container(
                  color: rowColor,
                  width: rowWidth - cellWidth,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: session.judgingPods.length,
                    itemBuilder: (context, index) {
                      return _buildJudgingSubRow(
                        teams,
                        session.judgingPods[index],
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget getJudgingTable() {
    // get the judging sessions that should be after the current system time
    List<JudgingSession> futureJudgingSessions = sortJudgingByTime(_futureJudgingSessions);
    // int maxItems = 3;
    // int itemCount = futureJudgingSessions.length > maxItems ? maxItems : futureJudgingSessions.length;
    int itemCount = 3;
    return LayoutBuilder(builder: ((context, constraints) {
      if (futureJudgingSessions.isEmpty || widget.teams.isEmpty) {
        return Container(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          color: Colors.white,
          child: const Center(
            child: Text(
              "No Sessions",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
        );
      } else {
        return SizedBox(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index >= futureJudgingSessions.length) {
                // add filler if there are less than 3 sessions
                return Container(
                  color: index.isEven ? Colors.white : Colors.grey[300]!,
                  height: constraints.maxHeight / itemCount,
                  width: constraints.maxWidth,
                );
              } else {
                return _buildRow(
                  widget.teams,
                  futureJudgingSessions[index],
                  index.isEven ? Colors.white : Colors.grey[300]!,
                  constraints.maxHeight / itemCount,
                  constraints.maxWidth,
                );
              }
            },
          ),
        );
      }
    }));
  }

  Widget getJudgingInfo(double height) {
    double fontSize = Responsive.isDesktop(context)
        ? 25
        : Responsive.isTablet(context)
            ? 20
            : 8;

    return LayoutBuilder(builder: ((context, constraints) {
      return SizedBox(
        height: height,
        width: constraints.maxWidth,
        child: Column(
          children: [
            // Header row
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  // header title
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
                    width: (constraints.maxWidth / 100) * 60,
                    child: Center(child: Text("Judging Schedule", style: TextStyle(fontSize: fontSize, color: Colors.white))),
                  ),

                  // ttl
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
                    child: Center(child: Text("TTL: N/A", style: TextStyle(fontSize: fontSize, color: Colors.white))),
                  ),
                ],
              ),
            ),

            Expanded(child: getJudgingTable()),
          ],
        ),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_currentState == JudgeInfoState.info) {
      return getJudgingInfo(widget.height ?? 160);
    } else {
      return const SizedBox.shrink();
    }
  }
}
