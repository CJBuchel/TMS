import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/views/referee_scoring/referee_scoring_footer/floating_score.dart';
import 'package:tms/views/referee_scoring/referee_scoring_footer/referee_scoring_footer.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/referee_scoring_header.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/game_scoring_widget.dart';

class RefereeScoring extends StatelessWidget {
  const RefereeScoring({Key? key}) : super(key: key);

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
                const RefereeScoringHeader(),
                // expanded scrollable list
                const Expanded(
                  child: Center(
                    child: GameScoringWidget(),
                  ),
                ),

                // footer
                RefereeScoringFooter(footerHeight: footerHeight),
              ],
            ),
          ),
          // floating score
          FloatingScore(score: 50, left: 0, bottom: footerHeight),
        ],
      ),
    );
  }
}
