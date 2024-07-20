import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/game_timer_provider.dart';
import 'package:tms/utils/tms_time_utils.dart';

class MatchTimer extends StatelessWidget {
  // idle style
  final bool soundEnabled;
  final TextStyle idleStyle;
  final TextStyle activeStyle;
  final TextStyle endgameStyle;
  final TextStyle stoppedStyle;

  const MatchTimer({
    Key? key,
    required this.idleStyle,
    required this.activeStyle,
    required this.endgameStyle,
    required this.stoppedStyle,
    required this.soundEnabled,
  }) : super(key: key);

  factory MatchTimer.withStyle(TextStyle style, {bool soundEnabled = false}) {
    return MatchTimer(
      idleStyle: style,
      activeStyle: style,
      endgameStyle: style,
      stoppedStyle: style,
      soundEnabled: soundEnabled,
    );
  }

  void _playAudio(String assetAudio) async {
    var player = AudioPlayer();
    player.setAsset(assetAudio).then((_) {
      player.play();
    });
  }

  factory MatchTimer.full({double? fontSize = 50, bool soundEnabled = false}) {
    return MatchTimer(
      soundEnabled: soundEnabled,
      idleStyle: TextStyle(
        fontSize: fontSize,
        color: Colors.white,
        fontFamily: "lcdbold",
      ),
      activeStyle: TextStyle(
        color: Colors.green,
        fontSize: fontSize,
        fontFamily: "lcdbold",
      ),
      endgameStyle: TextStyle(
        color: Colors.orange,
        fontSize: fontSize,
        fontFamily: "lcdbold",
      ),
      stoppedStyle: TextStyle(
        color: Colors.red,
        fontSize: fontSize,
        fontFamily: "lcdbold",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<GameTimerProvider>(context, listen: false).onTimerStateChange((state) {
      if (soundEnabled) {
        switch (state) {
          case TimerRunState.running:
            _playAudio("assets/audio/start.mp3");
            break;
          case TimerRunState.endgame:
            _playAudio("assets/audio/end-game.mp3");
            break;
          case TimerRunState.stopped:
            _playAudio("assets/audio/stop.mp3");
            break;
          case TimerRunState.ended:
            _playAudio("assets/audio/end.mp3");
            break;
          default:
            break;
        }
      }
    });

    return Selector<GameTimerProvider, ({TimerRunState state, int timer})>(
      selector: (context, provider) {
        return (
          state: provider.timerState,
          timer: provider.timer,
        );
      },
      builder: (context, value, _) {
        TextStyle style;

        switch (value.state) {
          case TimerRunState.idle:
            style = idleStyle;
            break;
          case TimerRunState.countdown:
            style = endgameStyle;
            if (soundEnabled) _playAudio("assets/audio/short-beep.mp3");
            break;
          case TimerRunState.running:
            style = activeStyle;
            break;
          case TimerRunState.endgame:
            style = endgameStyle;
            break;
          case TimerRunState.stopped:
            style = stoppedStyle;
            break;
          case TimerRunState.ended:
            style = stoppedStyle;
            break;
        }

        return Text(
          secondsToTimeString(value.timer),
          style: style,
        );
      },
    );
  }
}
