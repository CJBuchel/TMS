import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/providers/game_scoring_provider.dart';
import 'package:tms/providers/game_table_provider.dart';
import 'package:tms/views/referee_scoring/referee_scoring_footer/floating_score.dart';
import 'package:tms/views/referee_scoring/referee_scoring_footer/referee_scoring_footer.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/referee_scoring_header.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/game_scoring_widget.dart';
import 'package:tms/widgets/game_scoring/with_next_game_scoring.dart';

class RefereeScoring extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  RefereeScoring({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double footerHeight = 120;

    if (ResponsiveBreakpoints.of(context).isDesktop) {
      footerHeight = 120;
    } else if (ResponsiveBreakpoints.of(context).isTablet) {
      footerHeight = 120;
    } else if (ResponsiveBreakpoints.of(context).isMobile) {
      footerHeight = 100;
    }

    return EchoTreeLifetime(
      trees: [":robot_game:tables", ":robot_game:matches", ":teams"],
      child: Stack(
        children: [
          Container(
            child: Column(
              children: [
                // header
                WithNextGameScoring(builder: (context, nextMatch, nextTeam, totalMatches, round) {
                  return Selector<GameTableProvider, String>(
                    selector: (context, provider) => provider.localGameTable,
                    builder: (context, table, child) {
                      return RefereeScoringHeader(
                        nextMatch: nextMatch,
                        nextTeam: nextTeam,
                        totalMatches: totalMatches,
                        round: round,
                        table: table,
                      );
                    },
                  );
                }),
                // expanded scrollable list
                Expanded(
                  child: Center(
                    child: GameScoringWidget(scrollController: _scrollController),
                  ),
                ),

                // footer
                RefereeScoringFooter(
                  footerHeight: footerHeight,
                  scrollController: _scrollController,
                ),
              ],
            ),
          ),
          // floating score
          Selector<GameScoringProvider, int>(
            selector: (context, gs) => gs.score,
            builder: (context, score, child) {
              return FloatingScore(score: score, left: 0, bottom: footerHeight);
            },
          ),
        ],
      ),
    );
  }
}
