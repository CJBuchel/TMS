import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';

class NextMatchInfo extends StatelessWidget {
  final List<GameMatch> nextMatches;

  const NextMatchInfo({
    required this.nextMatches,
  });

  @override
  Widget build(BuildContext context) {
    return Text("Next matches");
  }
}
