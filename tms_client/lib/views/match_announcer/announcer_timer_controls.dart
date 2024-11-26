import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_status_provider.dart';
import 'package:tms/views/match_controller/timer_controls/start_buttons.dart';
import 'package:tms/widgets/timers/match_timer.dart';

class _MatchStatusData {
  bool isRunning;
  bool isReady;
  bool isLoaded;

  _MatchStatusData({
    required this.isRunning,
    required this.isReady,
    required this.isLoaded,
  });
}

class AnnouncerTimerControls extends StatelessWidget {
  Widget _statusText(String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 40,
            overflow: TextOverflow.ellipsis,
            color: color,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GameMatchStatusProvider, _MatchStatusData>(
      selector: (_, p) {
        return _MatchStatusData(
          isRunning: p.isMatchesRunning,
          isReady: p.isMatchesReady,
          isLoaded: p.loadedMatchNumbers.isNotEmpty,
        );
      },
      builder: (context, data, _) {
        if (data.isRunning) {
          return Center(
            child: MatchTimer.full(
              fontSize: 150,
              soundEnabled: true,
            ),
          );
        } else if (data.isReady) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: StartButtons(active: data.isReady),
            ),
          );
        } else if (data.isLoaded) {
          return _statusText('Not Ready', color: Colors.red);
        } else {
          return _statusText('No Matches Loaded');
        }
      },
    );
  }
}
