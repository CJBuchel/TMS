import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/judging_session.dart';
import 'package:tms/providers/judging_sessions_provider.dart';
import 'package:tms/views/scoreboard/judging_info/judging_info.dart';
import 'package:tms/views/scoreboard/matches_info/matches_info.dart';
import 'package:tms/views/scoreboard/scoreboard_header.dart';
import 'package:tms/views/scoreboard/teams_ranking_list/teams_ranking_list.dart';

class Scoreboard extends StatelessWidget {
  const Scoreboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [
        ":teams",
        ":judging:sessions",
        ":robot_game:game_scores",
        ":robot_game:matches",
      ],
      child: Container(
        child: Column(
          children: [
            ScoreboardHeader(),
            Selector<JudgingSessionsProvider, List<JudgingSession>>(
              selector: (_, provider) => provider.judgingSessionsByTime,
              builder: (context, judgingSessions, _) {
                return JudgingInfo(judgingSessions: judgingSessions);
              },
            ),
            Expanded(
              child: TeamsRankingList(),
            ),
            MatchesInfo(),
          ],
        ),
      ),
    );
  }
}
