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
  final bool? showOnlyClock;
  final bool autoFontSize;
  const JudgingTTLClock({
    Key? key,
    required this.sessions,
    this.fontSize,
    this.textColor,
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
            color: time >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    // every 1 second update the TTL clock
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.sessions.isNotEmpty) {
        List<JudgingSession> sessions = sortJudgingByTime(widget.sessions);
        for (final session in sessions) {
          DateTime? startTime = parseStringTimeToDateTime(session.startTime);

          // find the next judging session
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
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => getClock(_difference);
}
