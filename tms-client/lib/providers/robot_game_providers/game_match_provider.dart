import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/utils/sorter_util.dart';

class GameMatchProvider extends EchoTreeProvider<String, GameMatch> {
  // GameMatchService _service = GameMatchService();

  GameMatchProvider()
      : super(tree: ":robot_game:matches", fromJsonString: (json) => GameMatch.fromJsonString(json: json));

  List<GameMatch> get matches {
    // order matches by start time
    List<GameMatch> matches = this.items.values.toList();
    return sortMatchesByTime(matches);
  }

  // @TODO, modify and add matches
}
