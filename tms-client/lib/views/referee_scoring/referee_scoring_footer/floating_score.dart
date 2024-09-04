import 'package:flutter/material.dart';

class FloatingScore extends StatelessWidget {
  final int score;
  final double? bottom;
  final double? right;
  final double? left;
  final double? top;

  FloatingScore({
    Key? key,
    required this.score,
    this.bottom,
    this.right,
    this.left,
    this.top,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: bottom,
      right: right,
      left: left,
      top: top,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
        ),
        width: 120,
        height: 40,
        child: Center(
          child: Text(
            score.toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
