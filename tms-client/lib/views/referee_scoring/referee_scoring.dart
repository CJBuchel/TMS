import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:tms/views/referee_scoring/referee_scoring_footer/referee_scoring_footer.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/referee_scoring_header.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/game_scoring_widget.dart';

class RefereeScoring extends StatelessWidget {
  const RefereeScoring({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [":robot_game:tables", ":robot_game:matches", ":teams"],
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
          RefereeScoringFooter(),
        ],
      ),
    );
  }
}
