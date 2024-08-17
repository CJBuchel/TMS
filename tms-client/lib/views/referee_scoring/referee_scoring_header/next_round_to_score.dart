import 'package:flutter/material.dart';
import 'package:tms/widgets/game_scoring/with_next_game_scoring.dart';

class NextRoundToScore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WithNextGameScoring(
      builder: (context, _, __, ___, round) {
        return Text(
          "Round: $round",
          style: const TextStyle(
            fontSize: 16,
          ),
        );
      },
    );
  }
}
