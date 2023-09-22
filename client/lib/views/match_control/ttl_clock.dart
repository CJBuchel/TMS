import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';

class TTLClock extends StatefulWidget {
  final List<GameMatch> matches;
  const TTLClock({Key? key, required this.matches}) : super(key: key);

  @override
  State<TTLClock> createState() => _TTLClockState();
}

class _TTLClockState extends State<TTLClock> {
  Timer? _timer;
  int _difference = 0;
  String padTime(int value, int length) {
    return value.toString().padLeft(length, '0');
  }

  String parseTime(int time) {
    String hourTime = padTime(time.abs() ~/ 3600, 2);
    String minuteTime = padTime((time.abs() % 3600) ~/ 60, 2);
    String secondTime = padTime(time.abs() % 60, 2);
    return "$hourTime:$minuteTime:$secondTime";
  }

  DateTime? parseStringTime(String time) {
    final format24 = RegExp(r'^(\d{2}):(\d{2}):(\d{2}) (AM|PM)$');
    final matchTime = format24.firstMatch(time); // heh, matching match time
    if (matchTime != null) {
      final hour = int.parse(matchTime.group(1)!);
      final minute = int.parse(matchTime.group(2)!);
      final second = int.parse(matchTime.group(3)!);
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute, second);
    } else {
      return null;
    }
  }

  int getTimeDifference(String time) {
    int diff = parseStringTime(time)?.difference(DateTime.now()).inSeconds ?? 0;
    return diff;
  }

  Widget getClock(int time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "TTL: ",
          style: TextStyle(
            fontSize: Responsive.isDesktop(context) ? 60 : 40,
          ),
        ),
        Text(
          time >= 0 ? "+${parseTime(time)}" : "-${parseTime(time)}",
          style: TextStyle(
            fontFamily: "lcdbold",
            fontSize: Responsive.isDesktop(context) ? 60 : 40,
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
        setState(() {
          _difference = getTimeDifference(time);
        });
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
