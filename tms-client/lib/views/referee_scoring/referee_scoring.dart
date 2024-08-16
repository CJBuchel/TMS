import 'package:flutter/material.dart';

class RefereeScoring extends StatelessWidget {
  const RefereeScoring({Key? key}) : super(key: key);

  // top level, get team data, get match data pass through (includes high level input)
  // secondary level, get blueprint and question layout
  // low level, get question data and answer data inputs

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Referee Scoring'),
    );
  }
}
