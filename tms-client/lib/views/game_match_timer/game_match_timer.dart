import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_status_provider.dart';
import 'package:tms/views/game_match_timer/game_match_timer_footer.dart';
import 'package:tms/views/game_match_timer/game_match_timer_header.dart';
import 'package:tms/views/game_match_timer/timer_match_data.dart';
import 'package:tms/widgets/timers/match_timer.dart';

class GameMatchTimer extends StatelessWidget {
  GameMatchTimer({Key? key}) : super(key: key);

  final ValueNotifier<TimerMatchData> _timerMatchData = ValueNotifier<TimerMatchData>(
    TimerMatchData(
      loadedMatches: [],
      nextMatch: null,
    ),
  );

  Widget _matchInfoHeader() {
    return Selector2<GameMatchProvider, GameMatchStatusProvider, TimerMatchData>(
      selector: (context, gmProvider, gmsProvider) {
        _timerMatchData.value = TimerMatchData(
          loadedMatches: gmsProvider.getLoadedMatches(gmProvider.matches),
          nextMatch: gmProvider.nextMatch,
        );
        return _timerMatchData.value;
      },
      shouldRebuild: (previous, next) => !previous.compare(next),
      builder: (context, data, _) => GameMatchTimerHeader(data: data),
    );
  }

  Widget _matchInfoFooter(BuildContext context) {
    if (ResponsiveBreakpoints.of(context).isDesktop &&
        ResponsiveBreakpoints.of(context).orientation == Orientation.landscape) {
      return GameMatchTimerFooter(data: _timerMatchData);
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = 100;

    if (ResponsiveBreakpoints.of(context).isDesktop) {
      fontSize = 350;
    } else if (ResponsiveBreakpoints.of(context).isTablet) {
      fontSize = 250;
    } else if (ResponsiveBreakpoints.of(context).isMobile) {
      fontSize = 80;
    }

    return EchoTreeLifetime(
      trees: [
        ":robot_game:matches",
        ":robot_game:tables",
        ":teams",
      ],
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: _matchInfoHeader(),
          ),
          Expanded(
            child: Center(
              child: MatchTimer.full(
                fontSize: fontSize,
                soundEnabled: true,
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: _matchInfoFooter(context),
          ),
        ],
      ),
    );
  }
}
