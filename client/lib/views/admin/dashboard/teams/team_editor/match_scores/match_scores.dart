import 'package:flutter/material.dart';

class MatchScores extends StatelessWidget {
  final String teamNumber;
  const MatchScores({
    Key? key,
    required this.teamNumber,
  }) : super(key: key);

  Widget _table() {
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return _table();
    });
  }
}
