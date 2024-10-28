import 'package:tms/generated/infra/database_schemas/game_score_sheet.dart';

class TeamScoringData {
  final int teamRank;
  final String teamId;
  final String teamNumber;
  final String teamName;
  final List<GameScoreSheet> scores;

  TeamScoringData({
    required this.teamRank,
    required this.teamId,
    required this.teamNumber,
    required this.teamName,
    required this.scores,
  });
}
