import 'package:flutter/material.dart';
import 'package:tms/constants.dart';

class FloatingScore extends StatelessWidget {
  final double footerHeight;
  final int score;

  const FloatingScore({
    Key? key,
    required this.footerHeight,
    required this.score,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: footerHeight,
      left: 0,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10),
            topLeft: Radius.zero,
          ),
          border: Border.all(
            color: AppTheme.isDarkTheme ? Colors.white : Colors.black,
          ),
        ),
        width: 120,
        height: 60,
        child: Center(
          child: Text(
            score.toString(),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
