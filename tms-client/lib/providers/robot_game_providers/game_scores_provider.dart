import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:tms/generated/infra/database_schemas/game_score_sheet.dart';

class GameScoresProvider extends EchoTreeProvider<String, GameScoreSheet> {
  GameScoresProvider()
      : super(tree: ":robot_game:game_scores", fromJsonString: (json) => GameScoreSheet.fromJsonString(json: json));

  List<GameScoreSheet> get scores => items.values.toList();

  List<GameScoreSheet> getScoresByTeamId(String teamId) {
    return scores.where((score) => score.teamRefId == teamId).toList();
  }
}
