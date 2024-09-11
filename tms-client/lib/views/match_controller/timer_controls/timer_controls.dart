import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_status_provider.dart';
import 'package:tms/views/match_controller/timer_controls/abort_button.dart';
import 'package:tms/views/match_controller/timer_controls/start_buttons.dart';
import 'package:tms/widgets/timers/match_timer.dart';

class TimerControls extends StatelessWidget {
  const TimerControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<GameMatchStatusProvider, ({bool isReady, bool isRunning})>(
      selector: (_, provider) {
        return (
          isReady: provider.isMatchesReady,
          isRunning: provider.isMatchesRunning,
        );
      },
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, value, _) {
        return Column(
          children: [
            // Timer
            // Row of buttons (switch to abort/reload)
            Expanded(
              flex: 2,
              child: Center(
                child: MatchTimer.full(
                  fontSize: 100,
                  soundEnabled: true,
                ),
              ),
            ),

            Expanded(
              flex: 1,
              child: Center(
                child: value.isRunning ? const AbortButton() : StartButtons(active: value.isReady),
              ),
            ),
          ],
        );
      },
    );
  }
}
