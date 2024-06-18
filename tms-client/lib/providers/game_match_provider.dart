import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:tms/schemas/database_schema.dart';
import 'package:tms/utils/tms_date_time.dart';

class GameMatchProvider extends EchoTreeProvider<String, GameMatch> {
  GameMatchProvider()
      : super(
          tree: ":robot_game:matches",
          fromJson: (json) => GameMatch.fromJson(json),
        );

  List<GameMatch> get matches {
    // order matches by start time
    List<GameMatch> matches = this.items.values.toList();
    matches.sort((a, b) {
      // sort by start time
      return tmsDateTimeCompare(a.startTime, b.startTime);
    });

    return matches;
  }
}
