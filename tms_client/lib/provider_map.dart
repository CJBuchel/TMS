import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/auth_provider.dart';

// providers
import 'package:tms/providers/connection_provider.dart';
import 'package:tms/providers/judging_pod_provider.dart';
import 'package:tms/providers/judging_session_provider.dart';
import 'package:tms/providers/robot_game_providers/game_category_provider.dart';
import 'package:tms/providers/robot_game_providers/game_scores_provider.dart';
import 'package:tms/providers/robot_game_providers/game_scoring_provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/providers/robot_game_providers/game_table_provider.dart';
import 'package:tms/providers/robot_game_providers/game_table_signal_provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_status_provider.dart';
import 'package:tms/providers/tournament_config_provider.dart';
import 'package:tms/providers/game_timer_provider.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/providers/schedule_provider.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/providers/tournament_integrity_provider.dart';

class ProviderMap extends StatelessWidget {
  final Widget app;

  const ProviderMap({Key? key, required this.app}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TmsLocalStorageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => TournamentConfigProvider()),
        ChangeNotifierProvider(create: (_) => GameMatchProvider()),
        ChangeNotifierProvider(create: (_) => GameMatchStatusProvider()),
        ChangeNotifierProvider(create: (_) => GameTimerProvider()),
        ChangeNotifierProvider(create: (_) => TeamsProvider()),
        ChangeNotifierProvider(create: (_) => GameTableProvider()),
        ChangeNotifierProxyProvider<TournamentConfigProvider, GameScoringProvider>(
          create: (_) => GameScoringProvider(),
          update: (_, configProvider, scoringProvider) =>
              scoringProvider?.updateConfig(configProvider) ?? GameScoringProvider(),
        ),
        ChangeNotifierProvider(create: (_) => GameTableSignalProvider()),
        ChangeNotifierProvider(create: (_) => GameCategoryProvider()),
        ChangeNotifierProvider(create: (_) => GameScoresProvider()),
        ChangeNotifierProvider(create: (_) => JudgingSessionProvider()),
        ChangeNotifierProvider(create: (_) => JudgingPodProvider()),
        ChangeNotifierProvider(create: (_) => TournamentIntegrityProvider()),
      ],
      child: app,
    );
  }
}
