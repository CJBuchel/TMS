import 'package:flutter/material.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/next_match_to_score.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/next_round_to_score.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/next_team_to_score.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/select_game_table.dart';
import 'package:tms/widgets/game_scoring/with_next_game_scoring.dart';

class RefereeScoringHeader extends StatelessWidget {
  const RefereeScoringHeader({Key? key}) : super(key: key);

  Widget _headerRow() {
    return WithNextGameScoring(
      builder: (context, nextMatch, nextTeam, totalMatches, round) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // table name
            const SelectGameTable(),
            // next team to score
            NextTeamToScore(nextTeam: nextTeam),
            // next match to score
            NextMatchToScore(nextMatch: nextMatch, totalMatches: totalMatches),
            // next round to score
            NextRoundToScore(round: round),
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
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey : Colors.black,
            width: 1,
          ),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),

      // row of widgets
      child: _headerRow(),
    );
  }
}
