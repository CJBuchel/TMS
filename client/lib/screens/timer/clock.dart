import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/network/network.dart';
import 'package:tms/requests/event_requests.dart';
import 'package:tms/responsive.dart';

class Clock extends StatefulWidget {
  const Clock({Key? key}) : super(key: key);

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> with AutoUnsubScribeMixin {
  String padTime(int value, int length) {
    return value.toString().padLeft(length, '0');
  }

  String parseTime(double time) {
    if (time <= 30) {
      return "${time ~/ 1}";
    } else {
      String minuteTime = padTime(time ~/ 60, 2);
      String secondTime = padTime(time % 60 ~/ 1, 2);
      return "$minuteTime:$secondTime";
    }
  }

  static const _defaultTime = 150;
  int _time = _defaultTime; // default

  void getInitialTime() {
    getEventRequest().then((event) {
      if (event.item1 == HttpStatus.ok) {
        setState(() {
          _time = event.item2?.timerLength ?? _defaultTime;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    getInitialTime();

    autoSubscribe("event", (m) {
      if (m.subTopic == "update") {
        getInitialTime();
      }
    });

    autoSubscribe("clock", (m) {
      if (m.subTopic == "time" && m.message != null) {
        setState(() {
          _time = int.parse(m.message ?? "0");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return Text(
        parseTime(_time.toDouble()),
        style: const TextStyle(
          fontSize: 300,
          fontFamily: "Radioland",
        ),
      );
    } else if (Responsive.isTablet(context)) {
      return Text(
        parseTime(_time.toDouble()),
        style: const TextStyle(
          fontSize: 200,
          fontFamily: "Radioland",
        ),
      );
    } else {
      return Text(
        parseTime(_time.toDouble()),
        style: const TextStyle(
          fontSize: 80,
          fontFamily: "Radioland",
        ),
      );
    }
  }
}
