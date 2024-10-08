import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:tms/generated/infra/database_schemas/game_score_sheet.dart';

class GameScoresProvider extends EchoTreeProvider<String, GameScoreSheet> {
  GameScoresProvider()
      : super(tree: ":robot_game:game_scores", fromJsonString: (json) => GameScoreSheet.fromJsonString(json: json));

  List<GameScoreSheet> get scoresByTimestamp {
    var scores = items.values.toList();
    scores.sort((a, b) => a.timestamp.compareTo(other: b.timestamp));
    return scores;
  }

  List<GameScoreSheet> get scores => scoresByTimestamp;

  List<(String, GameScoreSheet)> get scoresWithId {
    // sort this by timestamp
    List<(String, GameScoreSheet)> entries = items.entries.map((entry) => (entry.key, entry.value)).toList();
    entries.sort((a, b) => a.$2.timestamp.compareTo(other: b.$2.timestamp));
    return entries;
  }

  List<GameScoreSheet> getScoresByTeamId(String teamId) {
    return scores.where((score) => score.teamRefId == teamId).toList();
  }

  List<(String, GameScoreSheet)> getScoresByTeamIdWithId(String teamId) {
    var entries = items.entries.where((entry) {
      return entry.value.teamRefId == teamId;
    }).toList();

    return entries.map((entry) => (entry.key, entry.value)).toList();
  }
}
