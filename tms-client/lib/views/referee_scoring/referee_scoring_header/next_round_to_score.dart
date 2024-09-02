import 'package:flutter/material.dart';

class NextRoundToScore extends StatelessWidget {
  final int round;
  final double fontSize;

  const NextRoundToScore({
    Key? key,
    this.round = 0,
    this.fontSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      "Round: $round",
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.white,
      ),
    );
  }
}
