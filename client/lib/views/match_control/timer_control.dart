import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/requests/timer_requests.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';

class TimerControl extends StatefulWidget {
  final List<GameMatch> loadedMatches;
  const TimerControl({Key? key, required this.loadedMatches}) : super(key: key);

  @override
  State<TimerControl> createState() => _TimerControlState();
}

enum TimerSendStatus {
  preStart,
  start,
  stop, // abort
  reload,
}

enum TimerState {
  idle,
  running,
  ended,
  stopped, // aborted
}

class _TimerControlState extends State<TimerControl> with AutoUnsubScribeMixin {
  TimerState _currentTimerState = TimerState.idle;
  double desktopButtonHeight = 40;
  double tabletButtonHeight = 35;
  double desktopButtonTextSize = 18;
  double tabletButtonTextSize = 14;
  void displayErrorDialog(int serverRes) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Unauthorised"),
        content: SingleChildScrollView(
          child: Text(serverRes == HttpStatus.unauthorized ? "Invalid User Permissions" : "Server Error"),
        ),
      ),
    );
  }

  Future<int> _sendTimerStatus(TimerSendStatus status) async {
    int statusCode = HttpStatus.ok;
    switch (status) {
      case TimerSendStatus.preStart:
        statusCode = await timerPreStartRequest();
        break;
      case TimerSendStatus.start:
        statusCode = await timerStartRequest();
        break;
      case TimerSendStatus.stop:
        statusCode = await timerStopRequest();
        break;
      case TimerSendStatus.reload:
        statusCode = await timerReloadRequest();
        break;
    }
    return statusCode;
  }

  void sendTimerStatus(TimerSendStatus status) async {
    int statusCode = await _sendTimerStatus(status);
    if (statusCode != HttpStatus.ok) {
      displayErrorDialog(statusCode);
    }
  }

  @override
  void initState() {
    super.initState();
    _currentTimerState = TimerState.idle;
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

  Widget getIdleConfig() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: SizedBox(
            height: Responsive.isDesktop(context) ? desktopButtonHeight : tabletButtonHeight,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    widget.loadedMatches.isNotEmpty ? MaterialStateProperty.all<Color>(Colors.orange) : MaterialStateProperty.all<Color>(Colors.grey),
              ),
              onPressed: () {
                if (widget.loadedMatches.isNotEmpty) {
                  sendTimerStatus(TimerSendStatus.preStart);
                }
              },
              child: Text("Pre-Start", style: TextStyle(fontSize: Responsive.isDesktop(context) ? desktopButtonTextSize : tabletButtonTextSize)),
            ),
          ),
        ),
        const SizedBox(width: 16), // spacing
        Expanded(
          child: SizedBox(
            height: Responsive.isDesktop(context) ? desktopButtonHeight : tabletButtonHeight,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    widget.loadedMatches.isNotEmpty ? MaterialStateProperty.all<Color>(Colors.green) : MaterialStateProperty.all<Color>(Colors.grey),
              ),
              onPressed: () {
                if (widget.loadedMatches.isNotEmpty) {
                  sendTimerStatus(TimerSendStatus.start);
                }
              },
              child: Text("Start", style: TextStyle(fontSize: Responsive.isDesktop(context) ? desktopButtonTextSize : tabletButtonTextSize)),
            ),
          ),
        ),
      ],
    );
  }

  Widget getRunningConfig() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: SizedBox(
            height: Responsive.isDesktop(context) ? desktopButtonHeight : tabletButtonHeight,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              onPressed: () {
                sendTimerStatus(TimerSendStatus.stop);
              },
              child: Text("Abort", style: TextStyle(fontSize: Responsive.isDesktop(context) ? desktopButtonTextSize : tabletButtonTextSize)),
            ),
          ),
        ),
      ],
    );
  }

  Widget getEndedConfig() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: SizedBox(
            height: Responsive.isDesktop(context) ? desktopButtonHeight : tabletButtonHeight,
            child: ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
              ),
              onPressed: () {
                sendTimerStatus(TimerSendStatus.reload);
              },
              icon: const Icon(Icons.replay),
              label: Text("Reload", style: TextStyle(fontSize: Responsive.isDesktop(context) ? desktopButtonTextSize : tabletButtonTextSize)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentTimerState) {
      case TimerState.idle:
        return getIdleConfig();
      case TimerState.running:
        return getRunningConfig();
      case TimerState.ended:
        return getEndedConfig();
      case TimerState.stopped:
        return getEndedConfig();
      default:
        return getIdleConfig();
    }
  }
}
