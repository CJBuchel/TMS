import 'package:flutter/material.dart';
import 'package:tms/widgets/game_scoring/with_next_game_scoring.dart';

class NextTeamToScore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WithNextGameScoring(
      builder: (context, nextMatch, nextTeam, _, __) {
        return Text(
          "${nextTeam?.number} | ${nextTeam?.name}",
          style: const TextStyle(
            fontSize: 16,
          ),
        );
      },
    );
  }
}
