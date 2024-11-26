import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_status_provider.dart';
import 'package:tms/views/match_announcer/announcer_timer_controls.dart';
import 'package:tms/views/match_announcer/next_match_header.dart';
import 'package:tms/views/match_announcer/next_match_info.dart';

class MatchAnnouncer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [
        ":teams",
        ":robot_game:matches",
      ],
      child: Selector2<GameMatchProvider, GameMatchStatusProvider, List<GameMatch>>(
        selector: (_, gmp, gsp) {
          List<GameMatch> loadedMatches = gsp.getLoadedMatches(gmp.matches);

          if (loadedMatches.isEmpty && gmp.nextMatch != null) {
            // get next matches
            return [gmp.nextMatch!];
          } else {
            // get loaded matches (current match)
            return loadedMatches;
          }
        },
        builder: (context, nextMatches, _) {
          return Column(
            children: [
              // banner (left match info/next/current, right Status time)
              Expanded(
                flex: 1,
                child: NextMatchHeader(nextMatches: nextMatches),
              ),
              Expanded(
                flex: 4,
                child: NextMatchInfo(
                  nextMatches: nextMatches,
                ),
              ),
              Expanded(
                flex: 2,
                child: AnnouncerTimerControls(),
              ),
            ],
          );
        },
      ),
    );
  }
}
