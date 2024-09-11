import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/widgets/timers/match_timer.dart';

class GameMatchTimer extends StatelessWidget {
  const GameMatchTimer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double fontSize = 100;

    if (ResponsiveBreakpoints.of(context).isDesktop) {
      fontSize = 400;
    } else if (ResponsiveBreakpoints.of(context).isTablet) {
      fontSize = 300;
    } else if (ResponsiveBreakpoints.of(context).isMobile) {
      fontSize = 250;
    }

    return Center(
      child: MatchTimer.full(
        fontSize: fontSize,
        soundEnabled: true,
      ),
    );
  }
}
