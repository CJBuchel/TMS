import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tms/network/network.dart';

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

  int _time = 150;

  @override
  void initState() {
    super.initState();
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
    return Text(
      parseTime(_time.toDouble()),
      style: const TextStyle(
        fontSize: 300,
        color: Colors.white,
        fontFamily: "Radioland",
      ),
    );
  }
}
