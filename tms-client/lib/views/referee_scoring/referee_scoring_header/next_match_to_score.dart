import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';

class NextMatchToScore extends StatelessWidget {
  final GameMatch? nextMatch;
  final int totalMatches;

  const NextMatchToScore({Key? key, this.nextMatch, this.totalMatches = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      "Match: ${nextMatch?.matchNumber}/${totalMatches}",
      style: const TextStyle(
        fontSize: 16,
      ),
    );
  }
}
