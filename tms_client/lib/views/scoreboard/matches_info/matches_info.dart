import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_status_provider.dart';
import 'package:tms/views/scoreboard/matches_info/loaded_match_timer.dart';
import 'package:tms/views/scoreboard/matches_info/matches_schedule.dart';

class MatchesInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<TmsLocalStorageProvider, bool>(
      selector: (_, provider) => provider.scoreboardShowMatchInfo,
      builder: (context, show, _) {
        return Selector2<
            GameMatchProvider,
            GameMatchStatusProvider,
            ({
              List<GameMatch> nextMatches,
              List<GameMatch> loadedMatches,
              bool isReadyOrRunning,
            })>(
          selector: (context, gmProvider, gmsProvider) {
            return (
              nextMatches: gmProvider.matchesByTime.where((m) => !m.completed).toList(),
              loadedMatches: gmsProvider.getLoadedMatches(gmProvider.matches),
              isReadyOrRunning: gmsProvider.isMatchesReady || gmsProvider.isMatchesRunning,
            );
          },
          builder: (context, data, _) {
            if (data.loadedMatches.isNotEmpty && data.isReadyOrRunning) {
              return LoadedMatchTimer(loadedMatches: data.loadedMatches);
            } else if (show) {
              return MatchesSchedule(matches: data.nextMatches);
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }
}
