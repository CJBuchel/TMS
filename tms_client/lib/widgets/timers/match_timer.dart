import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/game_timer_provider.dart';
import 'package:tms/utils/tms_time_utils.dart';

class MatchTimer extends StatefulWidget {
  final TextStyle idleStyle;
  final TextStyle activeStyle;
  final TextStyle endgameStyle;
  final TextStyle stoppedStyle;
  final bool soundEnabled;

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

  factory MatchTimer.full({double? fontSize = 50, bool soundEnabled = false}) {
    return MatchTimer(
      soundEnabled: soundEnabled,
      idleStyle: TextStyle(
        // use default color (in theme with the rest of the app)
        fontSize: fontSize,
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
  _MatchTimer createState() => _MatchTimer();
}

class _MatchTimer extends State<MatchTimer> {
  late GameTimerProvider _timerProvider;

  void _playAudio(String assetAudio) async {
    var player = AudioPlayer();
    player.setAsset(assetAudio).then((_) {
      player.play();
    });
  }

  void _stateChangeAudio(TimerRunState state) {
    if (widget.soundEnabled) {
      switch (state) {
        case TimerRunState.running:
          _playAudio("assets/audio/start.wav");
          break;
        case TimerRunState.endgame:
          _playAudio("assets/audio/end-game.wav");
          break;
        case TimerRunState.stopped:
          _playAudio("assets/audio/stop.wav");
          break;
        case TimerRunState.ended:
          _playAudio("assets/audio/end.wav");
          break;
        default:
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _timerProvider = Provider.of<GameTimerProvider>(context, listen: false);
    _timerProvider.addTimerStateChangeListener(_stateChangeAudio);
  }

  @override
  void dispose() {
    _timerProvider.removeTimerStateChangeListener(_stateChangeAudio);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            style = widget.idleStyle;
            break;
          case TimerRunState.countdown:
            style = widget.endgameStyle;
            if (widget.soundEnabled) _playAudio("assets/audio/short-beep.wav");
            break;
          case TimerRunState.running:
            style = widget.activeStyle;
            break;
          case TimerRunState.endgame:
            style = widget.endgameStyle;
            break;
          case TimerRunState.stopped:
            style = widget.stoppedStyle;
            break;
          case TimerRunState.ended:
            style = widget.stoppedStyle;
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
