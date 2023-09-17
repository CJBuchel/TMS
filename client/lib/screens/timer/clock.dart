import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/requests/event_requests.dart';
import 'package:tms/responsive.dart';
import 'package:just_audio/just_audio.dart';

class Clock extends StatefulWidget {
  final double? fontSize;
  const Clock({Key? key, this.fontSize}) : super(key: key);

  @override
  _ClockState createState() => _ClockState();
}

enum TimerClockState {
  idle,
  preStart,
  running,
  endgame,
  ended,
  stopped, // aborted
}

class _ClockState extends State<Clock> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  TimerClockState _TimerClockState = TimerClockState.idle;

  void playAudio(String assetAudio) async {
    if (kIsWeb) {
      var player = AudioPlayer();
      player.setAsset(assetAudio).then((value) {
        player.play();
      });
    } else {
      if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
        var player = AudioPlayer();
        player.setAsset(assetAudio).then((value) {
          player.play();
        });
      } else {
        print("Audio not supported on desktop");
      }
    }
  }

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

  TimerClockState get getState => _TimerClockState;

  @override
  void initState() {
    super.initState();

    // Update time on event update (db auto sync on initState so this will resolve itself)
    onEventUpdate((event) {
      setState(() {
        _time = event.timerLength;
      });
    });

    autoSubscribe("clock", (m) {
      if (m.subTopic == "time" && m.message != null) {
        if (_TimerClockState == TimerClockState.idle) {
          setState(() {
            _TimerClockState = TimerClockState.running;
          });
        }
        setState(() {
          _time = int.parse(m.message);
        });
      } else if (m.subTopic == "reload") {
        getInitialTime();
        setState(() {
          _TimerClockState = TimerClockState.idle;
        });
      } else if (m.subTopic == "start") {
        playAudio("assets/audio/start.mp3");
        setState(() {
          _TimerClockState = TimerClockState.running;
        });
      } else if (m.subTopic == "stop") {
        playAudio("assets/audio/stop.mp3");
        setState(() {
          _TimerClockState = TimerClockState.stopped;
        });
      } else if (m.subTopic == "endgame") {
        playAudio("assets/audio/end-game.mp3");
        setState(() {
          _TimerClockState = TimerClockState.endgame;
        });
      } else if (m.subTopic == "pre_start") {
        setState(() {
          _TimerClockState = TimerClockState.preStart;
        });
      } else if (m.subTopic == "end") {
        playAudio("assets/audio/end.mp3");
        setState(() {
          _TimerClockState = TimerClockState.ended;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color? timerColor = _TimerClockState == TimerClockState.running
        ? Colors.green
        : (_TimerClockState == TimerClockState.endgame || _TimerClockState == TimerClockState.preStart)
            ? Colors.yellow
            : (_TimerClockState == TimerClockState.ended || _TimerClockState == TimerClockState.stopped)
                ? Colors.red
                : null; // sets it to theme default (i.e white or black depending)

    if (widget.fontSize != null) {
      return Text(
        parseTime(_time.toDouble()),
        style: TextStyle(
          fontSize: widget.fontSize,
          color: timerColor,
          fontFamily: "lcdbold",
        ),
      );
    }

    if (Responsive.isDesktop(context)) {
      return Text(
        parseTime(_time.toDouble()),
        style: TextStyle(
          fontSize: 300,
          color: timerColor,
          fontFamily: "lcdbold",
        ),
      );
    } else if (Responsive.isTablet(context)) {
      return Text(
        parseTime(_time.toDouble()),
        style: TextStyle(
          fontSize: 200,
          color: timerColor,
          fontFamily: "lcdbold",
        ),
      );
    } else {
      return Text(
        parseTime(_time.toDouble()),
        style: TextStyle(
          fontSize: 80,
          color: timerColor,
          fontFamily: "lcdbold",
        ),
      );
    }
  }
}
