import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/views/scoreboard/matches_info/next_match_row.dart';
import 'package:tms/widgets/timers/match_schedule_timer.dart';

class MatchesSchedule extends StatelessWidget {
  final List<GameMatch> matches;

  const MatchesSchedule({Key? key, required this.matches}) : super(key: key);

  Widget _headerRow(BuildContext context) {
    Color? evenDarkBackground = const Color(0xFF1B6A92);
    Color? oddDarkBackground = const Color(0xFF27A07A);

    Color? evenLightBackground = const Color(0xFF9CDEFF);
    Color? oddLightBackground = const Color(0xFF81FFD7);

    Color? evenBackground = Theme.of(context).brightness == Brightness.light ? evenLightBackground : evenDarkBackground;
    Color? oddBackground = Theme.of(context).brightness == Brightness.light ? oddLightBackground : oddDarkBackground;

    GameMatch? nextMatch = matches.firstOrNull;

    return Container(
      height: 40,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: oddBackground,
              child: const Center(
                child: Text(
                  "Match Schedule",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: evenBackground,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Next: #${nextMatch?.matchNumber} (",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const MatchScheduleTimer(
                      positiveStyle: TextStyle(fontWeight: FontWeight.bold),
                      negativeStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const Text(")"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleList(BuildContext context) {
    Color? evenLightBackground = Theme.of(context).scaffoldBackgroundColor;
    Color? oddLightBackground = Theme.of(context).cardColor;

    Color? evenDarkBackground = Theme.of(context).scaffoldBackgroundColor;
    Color? oddDarkBackground = lighten(Theme.of(context).scaffoldBackgroundColor, 0.05);

    Color? evenBackground = Theme.of(context).brightness == Brightness.light ? evenLightBackground : evenDarkBackground;
    Color? oddBackground = Theme.of(context).brightness == Brightness.light ? oddLightBackground : oddDarkBackground;

    List<GameMatch> nextMatches = matches.take(3).toList();

    return Container(
      height: 160, // 3*40, then + 40 for header
      child: Column(
        children: [
          _headerRow(context),
          // generate rows for each match
          ...List<Widget>.generate(nextMatches.length, (index) {
            return Container(
              height: 40,
              color: index % 2 == 0 ? evenBackground : oddBackground,
              child: NextMatchRow(
                nextMatch: nextMatches[index],
                index: index,
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (matches.isNotEmpty) {
      return _scheduleList(context);
    } else {
      return const SizedBox.shrink();
    }
  }
}
