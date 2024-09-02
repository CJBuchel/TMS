import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/next_match_to_score.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/next_round_to_score.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/next_team_to_score.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/select_game_table.dart';
import 'package:tms/widgets/game_scoring/with_next_game_scoring.dart';

class RefereeScoringHeader extends StatelessWidget {
  const RefereeScoringHeader({Key? key}) : super(key: key);

  Widget _headerRow(BuildContext context) {
    double fontSize = 16;

    if (ResponsiveBreakpoints.of(context).isDesktop) {
      fontSize = 16;
    } else if (ResponsiveBreakpoints.of(context).isTablet) {
      fontSize = 12;
    } else {
      fontSize = 10;
    }

    return WithNextGameScoring(
      builder: (context, nextMatch, nextTeam, totalMatches, round) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // table name
            SelectGameTable(fontSize: fontSize),
            // next team to score
            NextTeamToScore(nextTeam: nextTeam, fontSize: fontSize),
            // next match to score
            NextMatchToScore(nextMatch: nextMatch, totalMatches: totalMatches, fontSize: fontSize),
            // next round to score
            NextRoundToScore(round: round, fontSize: fontSize),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        // color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Theme.of(context).cardColor,
        color: Theme.of(context).appBarTheme.backgroundColor,
        // bottom border only
        border: const Border(
          bottom: BorderSide(
            color: Colors.black,
            // color: Theme.of(context).brightness == Brightness.dark ? Colors.grey : Colors.black,
            width: 1,
          ),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),

      // row of widgets
      child: _headerRow(context),
    );
  }
}
