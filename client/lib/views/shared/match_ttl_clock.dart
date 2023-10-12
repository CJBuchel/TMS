import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/parse_util.dart';

class MatchTTLClock extends StatefulWidget {
  final List<GameMatch> matches;
  final double? fontSize;
  final Color? textColor;
  final bool? showOnlyClock;
  const MatchTTLClock({
    Key? key,
    required this.matches,
    this.fontSize,
    this.textColor,
    this.showOnlyClock,
  }) : super(key: key);

  @override
  State<MatchTTLClock> createState() => _TTLClockState();
}

class _TTLClockState extends State<MatchTTLClock> {
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.showOnlyClock == null || widget.showOnlyClock == false)
          Text(
            "TTL: ",
            style: TextStyle(
              fontSize: widget.fontSize ?? (Responsive.isDesktop(context) ? 60 : 40),
              color: widget.textColor,
            ),
          ),
        Text(
          time >= 0 ? "+${parseTime(time)}" : "-${parseTime(time)}",
          style: TextStyle(
            fontFamily: "lcdbold",
            fontSize: widget.fontSize ?? (Responsive.isDesktop(context) ? 60 : 40),
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
      if (widget.matches.isNotEmpty) {
        // find first match that hasn't been completed and use the start time
        String time = widget.matches.firstWhere((m) => (m.complete == false && m.gameMatchDeferred == false)).startTime;
        if (mounted) {
          setState(() {
            _difference = getTimeDifference(time);
          });
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
