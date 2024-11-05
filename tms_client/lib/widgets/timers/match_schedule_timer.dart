import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/tms_time/tms_date_time.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/utils/sorter_util.dart';
import 'package:tms/utils/tms_time_utils.dart';
import 'package:tms/widgets/timers/time_until.dart';

class MatchScheduleTimer extends StatelessWidget {
  final bool live;
  final TextStyle? positiveStyle;
  final TextStyle? negativeStyle;

  const MatchScheduleTimer({
    Key? key,
    this.live = true,
    this.positiveStyle,
    this.negativeStyle,
  }) : super(key: key);

  TmsDateTime getNextScheduledTime(List<GameMatch> matches) {
    // sort matches by time
    List<GameMatch> sortedMatches = sortMatchesByTime(matches);

    if (live) {
      // find the first match that is not completed
      for (GameMatch match in sortedMatches) {
        if (!match.completed) {
          return match.startTime;
        }
      }
    } else {
      // find the first match that is ahead of current time
      for (GameMatch match in sortedMatches) {
        DateTime startTime = tmsDateTimeToDateTime(match.startTime);
        if (startTime.isAfter(DateTime.now())) {
          return match.startTime;
        }
      }
    }

    return TmsDateTime();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GameMatchProvider, List<GameMatch>>(
      selector: (context, provider) => provider.matches,
      shouldRebuild: (previous, next) => !listEquals(previous, next),
      builder: (context, matches, child) {
        return TimeUntil(
          time: getNextScheduledTime(matches),
          positiveStyle: positiveStyle,
          negativeStyle: negativeStyle,
        );
      },
    );
  }
}
