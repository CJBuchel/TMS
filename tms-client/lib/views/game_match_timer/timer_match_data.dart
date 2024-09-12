import 'package:flutter/foundation.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';

class TimerMatchData {
  final List<GameMatch> loadedMatches;
  final GameMatch? nextMatch;

  TimerMatchData({
    required this.loadedMatches,
    required this.nextMatch,
  });

  bool compare(TimerMatchData other) {
    return listEquals(loadedMatches, other.loadedMatches) && nextMatch == other.nextMatch;
  }
}
