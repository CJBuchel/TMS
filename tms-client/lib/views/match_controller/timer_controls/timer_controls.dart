import 'package:flutter/material.dart';
import 'package:tms/views/match_controller/timer_controls/start_buttons.dart';
import 'package:tms/widgets/timers/match_timer.dart';

class TimerControls extends StatelessWidget {
  const TimerControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Timer
        // Row of buttons (switch to abort/reload)
        Expanded(
          flex: 2,
          child: Center(
            child: MatchTimer.full(
              fontSize: 100,
            ),
          ),
        ),

        Expanded(
          flex: 1,
          child: Center(
            child: StartButtons(),
          ),
        ),
      ],
    );
  }
}
