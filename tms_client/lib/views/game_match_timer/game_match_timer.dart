import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_status_provider.dart';
import 'package:tms/views/game_match_timer/game_match_timer_footer/game_match_timer_footer.dart';
import 'package:tms/views/game_match_timer/game_match_timer_header.dart';
import 'package:tms/models/timer_match_data.dart';
import 'package:tms/widgets/timers/match_timer.dart';

class GameMatchTimer extends StatelessWidget {
  GameMatchTimer({Key? key}) : super(key: key);

  Widget _matchInfoHeader() {
    return Selector2<GameMatchProvider, GameMatchStatusProvider, TimerMatchData>(
      selector: (context, gmProvider, gmsProvider) {
        return TimerMatchData(
          loadedMatches: gmsProvider.getLoadedMatches(gmProvider.matches),
          nextMatch: gmProvider.nextMatch,
        );
      },
      shouldRebuild: (previous, next) => !previous.compare(next),
      builder: (context, data, _) => GameMatchTimerHeader(data: data),
    );
  }

  Widget _matchInfoFooter(BuildContext context) {
    if (ResponsiveBreakpoints.of(context).isDesktop &&
        MediaQuery.of(context).size.height > 820 &&
        ResponsiveBreakpoints.of(context).orientation == Orientation.landscape) {
      return Selector2<GameMatchProvider, GameMatchStatusProvider, TimerMatchData>(
        selector: (context, gmProvider, gmsProvider) {
          return TimerMatchData(
            loadedMatches: gmsProvider.getLoadedMatches(gmProvider.matches),
            nextMatch: gmProvider.nextMatch,
          );
        },
        shouldRebuild: (previous, next) => !previous.compare(next),
        builder: (context, data, _) => GameMatchTimerFooter(data: data),
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = 100;

    if (ResponsiveBreakpoints.of(context).isDesktop && MediaQuery.of(context).size.height > 820) {
      fontSize = 350;
    } else if (ResponsiveBreakpoints.of(context).isTablet || MediaQuery.of(context).size.height < 820) {
      fontSize = 250;
    } else if (ResponsiveBreakpoints.of(context).isMobile || MediaQuery.of(context).size.height < 600) {
      fontSize = 80;
    }

    return EchoTreeLifetime(
      trees: [
        ":robot_game:matches",
        ":robot_game:tables",
        ":teams",
      ],
      child: Stack(
        children: [
          // match timer in the center
          Center(
            child: MatchTimer.full(
              fontSize: fontSize,
              soundEnabled: true,
            ),
          ),

          // header on top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _matchInfoHeader(),
          ),

          // footer at the bottom
          Positioned(
            bottom: 25,
            left: 0,
            right: 0,
            child: _matchInfoFooter(context),
          ),
        ],
      ),
    );
  }
}
