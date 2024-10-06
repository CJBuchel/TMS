import 'package:tms/generated/infra/database_schemas/game_score_sheet.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/utils/sorter_util.dart';

class TeamDataModel {
  final String teamId;
  final Team team;
  final List<GameScoreSheet> scores;

  const TeamDataModel(
    this.teamId,
    this.team,
    this.scores,
  );

  static List<TeamDataModel> sort(List<TeamDataModel> data) {
    data.sort((a, b) {
      int rankComparison = a.team.ranking.compareTo(b.team.ranking);

      if (rankComparison == 0) {
        int aTeamNumber = extractTeamNumber(a.team.teamNumber);
        int bTeamNumber = extractTeamNumber(b.team.teamNumber);
        if (aTeamNumber != bTeamNumber) {
          return aTeamNumber.compareTo(bTeamNumber);
        }
      }

      return rankComparison;
    });

    return data;
  }
}
