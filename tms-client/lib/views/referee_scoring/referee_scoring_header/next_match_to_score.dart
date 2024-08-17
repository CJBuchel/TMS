import 'package:flutter/material.dart';
import 'package:tms/widgets/game_scoring/with_next_game_scoring.dart';

class NextMatchToScore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WithNextGameScoring(
      builder: (context, nextMatch, nextTeam, totalMatches, _) {
        return Text(
          "Match: ${nextMatch?.matchNumber}/${totalMatches}",
          style: const TextStyle(
            fontSize: 16,
          ),
        );
      },
    );
  }
}
