import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/requests/timer_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/match_control/controls/controls_shared.dart';
import 'package:tms/views/match_control/tables/staging_table.dart';
import 'package:tms/views/match_control/timer_control.dart';
import 'package:tms/views/shared/tool_bar.dart';
import 'package:tms/views/timer/clock.dart';

class MatchControlMobileControls extends StatefulWidget {
  final List<Team> teams;
  final List<GameMatch> matches;
  final List<GameMatch> loadedMatches;
  final List<GameMatch> selectedMatches;
  const MatchControlMobileControls({
    Key? key,
    required this.teams,
    required this.matches,
    required this.loadedMatches,
    required this.selectedMatches,
  }) : super(key: key);

  @override
  State<MatchControlMobileControls> createState() => _MatchControlMobileControlsState();
}

class _MatchControlMobileControlsState extends State<MatchControlMobileControls> with AutoUnsubScribeMixin {
  TimerState _currentTimerState = TimerState.idle;
  @override
  void initState() {
    super.initState();

    autoSubscribe("clock", (m) {
      if (m.subTopic == "time" || m.subTopic == "start") {
        setState(() {
          _currentTimerState = TimerState.running;
        });
      } else if (m.subTopic == "end") {
        setState(() {
          _currentTimerState = TimerState.ended;
        });
      } else if (m.subTopic == "stop") {
        setState(() {
          _currentTimerState = TimerState.stopped;
        });
      } else if (m.subTopic == "reload") {
        setState(() {
          _currentTimerState = TimerState.idle;
        });
      }
    });
  }

  void sendTimerStatus(TimerSendStatus status) {
    switch (status) {
      case TimerSendStatus.preStart:
        timerPreStartRequest().then((res) {
          if (res != HttpStatus.ok) {
            displayErrorDialog(res, context);
          }
        });
        break;
      case TimerSendStatus.start:
        timerStartRequest().then((res) {
          if (res != HttpStatus.ok) {
            displayErrorDialog(res, context);
          }
        });
        break;
      case TimerSendStatus.stop:
        timerStopRequest().then((res) {
          if (res != HttpStatus.ok) {
            displayErrorDialog(res, context);
          } else {
            timerReloadRequest().then((res) {
              if (res != HttpStatus.ok) {
                displayErrorDialog(res, context);
              } else {
                Navigator.pop(context);
              }
            });
          }
        });
        break;
      case TimerSendStatus.reload:
        if (_currentTimerState == TimerState.ended) {
          timerReloadRequest().then((res) {
            if (res != HttpStatus.ok) {
              displayErrorDialog(res, context);
            } else {
              Navigator.pop(context);
            }
          });
        } else {
          timerReloadRequest().then((res) {
            if (res != HttpStatus.ok) {
              displayErrorDialog(res, context);
            }
          });
        }
        break;
    }
  }

  Widget getConfig() {
    switch (_currentTimerState) {
      case TimerState.idle:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              heroTag: "pre-start",
              onPressed: () {
                if (widget.loadedMatches.isNotEmpty) {
                  sendTimerStatus(TimerSendStatus.preStart);
                }
              },
              enableFeedback: true,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.play_arrow_sharp, color: Colors.white),
            ),
            FloatingActionButton(
              heroTag: "start",
              onPressed: () {
                if (widget.loadedMatches.isNotEmpty) {
                  sendTimerStatus(TimerSendStatus.start);
                }
              },
              enableFeedback: true,
              backgroundColor: Colors.green,
              child: const Icon(Icons.double_arrow, color: Colors.white),
            ),
          ],
        );
      case TimerState.running:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              heroTag: "stop",
              onPressed: () {
                if (widget.loadedMatches.isNotEmpty) {
                  sendTimerStatus(TimerSendStatus.stop);
                }
              },
              enableFeedback: true,
              backgroundColor: Colors.red,
              child: const Icon(Icons.stop, color: Colors.white),
            ),
          ],
        );

      case TimerState.stopped:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              heroTag: "reload",
              onPressed: () {
                if (widget.loadedMatches.isNotEmpty) {
                  sendTimerStatus(TimerSendStatus.reload);
                }
              },
              enableFeedback: true,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
          ],
        );

      case TimerState.ended:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              heroTag: "reload",
              onPressed: () {
                if (widget.loadedMatches.isNotEmpty) {
                  sendTimerStatus(TimerSendStatus.reload);
                }
              },
              enableFeedback: true,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TmsToolBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: SizedBox(
                  height: constraints.maxHeight / 2,
                  child: StagingTable(
                    teams: widget.teams,
                    loadedMatches: widget.loadedMatches,
                    selectedMatches: widget.selectedMatches,
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: constraints.maxHeight / 2,
                  child: const Center(child: Clock(fontSize: 100)),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: getConfig(),
    );
  }
}
