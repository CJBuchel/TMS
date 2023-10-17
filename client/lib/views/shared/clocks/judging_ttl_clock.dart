import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/parse_util.dart';
import 'package:tms/utils/sorter_util.dart';

class JudgingTTLClock extends StatefulWidget {
  final List<JudgingSession> sessions;
  final double? fontSize;
  final Color? textColor;
  final Color? timerColor;
  final bool? showOnlyClock;
  final bool autoFontSize;
  final bool live;

  const JudgingTTLClock({
    Key? key,
    required this.sessions,
    required this.live,
    this.fontSize,
    this.textColor,
    this.timerColor,
    this.showOnlyClock,
    this.autoFontSize = true,
  }) : super(key: key);

  @override
  State<JudgingTTLClock> createState() => _TTLClockState();
}

class _TTLClockState extends State<JudgingTTLClock> {
  Timer? _timer;
  int _difference = 0;

  String padTime(int value, int length) {
    return value.toString().padLeft(length, '0');
  }

  int getTimeDifference(String time) {
    int diff = parseStringTimeToDateTime(time)?.difference(DateTime.now()).inSeconds ?? 0;
    return diff;
  }

  Widget getClock(int time) {
    double? fontSize = widget.autoFontSize ? widget.fontSize ?? (Responsive.isDesktop(context) ? 60 : 40) : 18;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.showOnlyClock == null || widget.showOnlyClock == false)
          Text(
            "TTL: ",
            style: TextStyle(
              fontSize: fontSize,
              color: widget.textColor,
            ),
          ),
        Text(
          time >= 0 ? "+${parseTime(time)}" : "-${parseTime(time)}",
          style: TextStyle(
            fontFamily: "lcdbold",
            fontSize: fontSize,
            color: widget.timerColor ?? (time >= 0 ? Colors.green : Colors.red),
          ),
        ),
      ],
    );
  }

  void _setLive(List<JudgingSession> sessions) {
    String time = "";

    for (var session in sessions) {
      if (session.complete == false && session.judgingSessionDeferred == false) {
        time = session.startTime;
        break;
      }
    }

    if (mounted) {
      setState(() {
        _difference = getTimeDifference(time);
      });
    }
  }

  void _setNext(List<JudgingSession> sessions) {
    for (final session in sessions) {
      DateTime? startTime = parseStringTimeToDateTime(session.startTime);
      if (startTime != null && startTime.isAfter(DateTime.now())) {
        int diff = startTime.difference(DateTime.now()).inSeconds;
        if (mounted) {
          setState(() {
            _difference = diff;
          });
        }
        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // every 1 second update the TTL clock
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.sessions.isNotEmpty) {
        if (widget.live) {
          _setLive(sortJudgingByTime(widget.sessions));
        } else {
          _setNext(sortJudgingByTime(widget.sessions));
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return getClock(_difference);
  }
}
