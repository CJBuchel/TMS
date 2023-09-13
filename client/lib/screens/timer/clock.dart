import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/requests/event_requests.dart';
import 'package:tms/responsive.dart';
import 'package:audioplayers/audioplayers.dart';

class Clock extends StatefulWidget {
  final double? fontSize;
  const Clock({Key? key, this.fontSize}) : super(key: key);

  @override
  State<Clock> createState() => _ClockState();
}

enum TimerState {
  idle,
  preStart,
  running,
  endgame,
  ended,
  stopped, // aborted
}

class _ClockState extends State<Clock> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  final player = AudioPlayer();
  TimerState _timerState = TimerState.idle;
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

    player.setVolume(1.0);

    // Update time on event update (db auto sync on initState so this will resolve itself)
    onEventUpdate((event) {
      setState(() {
        _time = event.timerLength;
      });
    });

    autoSubscribe("clock", (m) {
      if (m.subTopic == "time" && m.message != null) {
        if (_timerState == TimerState.idle) {
          setState(() {
            _timerState = TimerState.running;
          });
        }
        setState(() {
          _time = int.parse(m.message ?? "0");
        });
      } else if (m.subTopic == "reload") {
        getInitialTime();
        setState(() {
          _timerState = TimerState.idle;
        });
      } else if (m.subTopic == "start") {
        player.play(AssetSource("audio/start.mp3"));
        setState(() {
          _timerState = TimerState.running;
        });
      } else if (m.subTopic == "stop") {
        player.play(AssetSource("audio/stop.mp3"));
        setState(() {
          _timerState = TimerState.stopped;
        });
      } else if (m.subTopic == "endgame") {
        player.play(AssetSource("audio/end-game.mp3"));
        setState(() {
          _timerState = TimerState.endgame;
        });
      } else if (m.subTopic == "pre_start") {
        setState(() {
          _timerState = TimerState.preStart;
        });
      } else if (m.subTopic == "end") {
        player.play(AssetSource("audio/end.mp3"));
        setState(() {
          _timerState = TimerState.ended;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color timerColor = _timerState == TimerState.running
        ? Colors.green
        : (_timerState == TimerState.endgame || _timerState == TimerState.preStart)
            ? Colors.yellow
            : (_timerState == TimerState.ended || _timerState == TimerState.stopped)
                ? Colors.red
                : Colors.white;

    if (widget.fontSize != null) {
      return Text(
        parseTime(_time.toDouble()),
        style: TextStyle(
          fontSize: widget.fontSize,
          color: timerColor,
          fontFamily: "Radioland",
        ),
      );
    }

    if (Responsive.isDesktop(context)) {
      return Text(
        parseTime(_time.toDouble()),
        style: TextStyle(
          fontSize: 300,
          color: timerColor,
          fontFamily: "Radioland",
        ),
      );
    } else if (Responsive.isTablet(context)) {
      return Text(
        parseTime(_time.toDouble()),
        style: TextStyle(
          fontSize: 200,
          color: timerColor,
          fontFamily: "Radioland",
        ),
      );
    } else {
      return Text(
        parseTime(_time.toDouble()),
        style: TextStyle(
          fontSize: 80,
          color: timerColor,
          fontFamily: "Radioland",
        ),
      );
    }
  }
}
