import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_status_provider.dart';
import 'package:tms/widgets/timers/match_timer.dart';

class FloatingTimer extends StatelessWidget {
  final double? bottom;
  final double? right;
  final double? left;
  final double? top;

  FloatingTimer({
    Key? key,
    this.bottom,
    this.right,
    this.left,
    this.top,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<GameMatchStatusProvider, ({bool isReady, bool isRunning})>(
      selector: (_, provider) {
        return (
          isReady: provider.isMatchesReady,
          isRunning: provider.isMatchesRunning,
        );
      },
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, matchStatus, _) {
        if (matchStatus.isReady || matchStatus.isRunning) {
          return Positioned(
            bottom: bottom,
            right: right,
            left: left,
            top: top,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                // border only the top right
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              width: 150,
              height: 40,
              child: Center(
                child: MatchTimer.withStyle(
                  const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
