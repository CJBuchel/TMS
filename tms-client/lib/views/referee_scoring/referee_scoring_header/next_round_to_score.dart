import 'package:flutter/material.dart';

class NextRoundToScore extends StatelessWidget {
  final int round;

  const NextRoundToScore({
    Key? key,
    this.round = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      "Round: $round",
      style: const TextStyle(
        fontSize: 16,
      ),
    );
  }
}
