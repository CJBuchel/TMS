import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:tms/views/scoreboard/scoreboard_header.dart';
import 'package:tms/views/scoreboard/teams_ranking_list/teams_ranking_list.dart';

class Scoreboard extends StatelessWidget {
  const Scoreboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [
        ":teams",
        ":robot_game:game_scores",
      ],
      child: Container(
        child: Column(
          children: [
            ScoreboardHeader(),
            Expanded(
              child: TeamsRankingList(),
            ),
          ],
        ),
      ),
    );
  }
}
