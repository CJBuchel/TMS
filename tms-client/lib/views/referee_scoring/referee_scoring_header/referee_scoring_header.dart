import 'package:flutter/material.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/next_match_to_score.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/next_round_to_score.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/next_team_to_score.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/select_game_table.dart';

class RefereeScoringHeader extends StatelessWidget {
  Widget _headerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // table name
        SelectGameTable(),
        // next team to score
        NextTeamToScore(),
        // next match to score
        NextMatchToScore(),
        // next round to score
        NextRoundToScore(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Theme.of(context).cardColor,
        // bottom border only
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey : Colors.transparent,
            width: 1,
          ),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),

      // row of widgets
      child: FutureBuilder(
        future: Future.delayed(const Duration(milliseconds: 500)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            TmsLogger().w("Rebuilt RefereeScoringHeader");
            return _headerRow();
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
