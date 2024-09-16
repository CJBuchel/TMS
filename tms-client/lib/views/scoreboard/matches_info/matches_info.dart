import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/views/scoreboard/matches_info/next_match_row.dart';
import 'package:tms/widgets/timers/match_live_schedule_timer.dart';

class MatchesInfo extends StatelessWidget {
  Widget _headerRow(BuildContext context) {
    Color? evenDarkBackground = const Color(0xFF1B6A92);
    Color? oddDarkBackground = const Color(0xFF27A07A);

    Color? evenLightBackground = const Color(0xFF9CDEFF);
    Color? oddLightBackground = const Color(0xFF81FFD7);

    Color? evenBackground = Theme.of(context).brightness == Brightness.light ? evenLightBackground : evenDarkBackground;
    Color? oddBackground = Theme.of(context).brightness == Brightness.light ? oddLightBackground : oddDarkBackground;

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
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Next: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    MatchLiveScheduleTimer(
                      positiveStyle: TextStyle(fontWeight: FontWeight.bold),
                      negativeStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color? evenLightBackground = Theme.of(context).scaffoldBackgroundColor;
    Color? oddLightBackground = Theme.of(context).cardColor;

    Color? evenDarkBackground = Theme.of(context).scaffoldBackgroundColor;
    Color? oddDarkBackground = lighten(Theme.of(context).scaffoldBackgroundColor, 0.05);

    Color? evenBackground = Theme.of(context).brightness == Brightness.light ? evenLightBackground : evenDarkBackground;
    Color? oddBackground = Theme.of(context).brightness == Brightness.light ? oddLightBackground : oddDarkBackground;

    return Selector<TmsLocalStorageProvider, bool>(
      selector: (_, provider) => provider.scoreboardShowMatchInfo,
      builder: (context, show, _) {
        if (show) {
          return Selector<GameMatchProvider, List<GameMatch>>(
            selector: (_, provider) {
              // get the next 3 matches

              return provider.matchesByTime.where((match) => !match.completed).take(3).toList();
            },
            builder: (context, nextMatches, child) {
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
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
