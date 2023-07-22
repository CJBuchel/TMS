import 'dart:ffi';

import 'package:flutter/material.dart';

class Clock extends StatefulWidget {
  const Clock({Key? key}) : super(key: key);

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
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

  @override
  Widget build(BuildContext context) {
    return Text(
      parseTime(150),
      style: const TextStyle(
        fontSize: 300,
        color: Colors.white,
        fontFamily: "Radioland",
      ),
    );
  }
}
