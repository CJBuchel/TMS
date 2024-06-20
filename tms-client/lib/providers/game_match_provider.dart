import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
// import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/schemas/database_schema.dart';
import 'package:tms/utils/tms_date_time.dart';

class GameMatchProvider extends EchoTreeProvider<String, GameMatch> {
  GameMatchProvider()
      : super(
          tree: ":robot_game:matches",
          fromJson: (json) => GameMatch.fromJson(json),
        );

  List<GameMatch> stagedMatched = [];

  bool isMatchStaged(GameMatch match) {
    return stagedMatches.contains(match);
  }

  List<GameMatch> get matches {
    // order matches by start time
    List<GameMatch> matches = this.items.values.toList();
    matches.sort((a, b) {
      // sort by start time
      return tmsDateTimeCompare(a.startTime, b.startTime);
    });

    return matches;
  }

  List<GameMatch> get stagedMatches => stagedMatched;

  set stageMatches(List<GameMatch> matches) {
    stagedMatched = matches;
    notifyListeners();
  }

  void addMatchToStage(GameMatch match) {
    // add match if not already staged
    if (!stagedMatches.contains(match)) {
      stagedMatches.add(match);
      notifyListeners();
    }
  }

  void removeMatchFromStage(GameMatch match) {
    // remove match if staged
    if (stagedMatches.contains(match)) {
      stagedMatches.remove(match);
      notifyListeners();
    }
  }

  void loadMatches(List<GameMatch> matches) {}
  void setMatchCompleted(GameMatch match) {}
  void setMatchIncomplete(GameMatch match) {}
}
