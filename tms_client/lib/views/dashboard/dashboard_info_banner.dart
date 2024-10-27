import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/judging_session_provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/providers/robot_game_providers/game_scores_provider.dart';

class _Data {
  final int completedMatches;
  final int totalMatches;

  final int completedSessions;
  final int totalSessions;

  final int completedScoreSubmissions;
  final int totalScoreSubmissions;

  _Data({
    required this.completedMatches,
    required this.totalMatches,
    required this.completedSessions,
    required this.totalSessions,
    required this.completedScoreSubmissions,
    required this.totalScoreSubmissions,
  });
}

class DashboardInfoBanner extends StatelessWidget {
  Widget _buildProgressIndicator({
    required String label,
    required int completed,
    required int total,
    Color color = Colors.blue,
  }) {
    double progress = total > 0 ? completed / total : 0.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularPercentIndicator(
          animation: true,
          radius: 30.0,
          lineWidth: 6.0,
          percent: progress,
          center: Text("$completed/$total"),
          progressColor: color,
          footer: Text(label),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector3<GameMatchProvider, JudgingSessionProvider, GameScoresProvider, _Data>(
      selector: (_, gmp, jsp, gsp) {
        return _Data(
          completedMatches: gmp.matches.where((m) => m.completed).length,
          totalMatches: gmp.matches.length,
          completedSessions: jsp.judgingSessions.where((s) => s.completed).length,
          totalSessions: jsp.judgingSessions.length,
          completedScoreSubmissions: gsp.scores.length,
          // count the number of tables on each match
          totalScoreSubmissions: gmp.matches.fold<int>(0, (prev, match) {
            return prev + match.gameMatchTables.length;
          }),
        );
      },
      builder: (context, data, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProgressIndicator(
              label: "Matches",
              completed: data.completedMatches,
              total: data.totalMatches,
              color: Colors.green,
            ),
            _buildProgressIndicator(
              label: "Sessions",
              completed: data.completedSessions,
              total: data.totalSessions,
              color: Colors.blue,
            ),
            _buildProgressIndicator(
              label: "Game Scores",
              completed: data.completedScoreSubmissions,
              total: data.totalScoreSubmissions,
              color: Colors.purple,
            ),
          ],
        );
      },
    );
  }
}
