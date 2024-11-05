import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/judging_session.dart';
import 'package:tms/generated/infra/database_schemas/tms_time/tms_date_time.dart';
import 'package:tms/providers/judging_session_provider.dart';
import 'package:tms/utils/sorter_util.dart';
import 'package:tms/utils/tms_time_utils.dart';
import 'package:tms/widgets/timers/time_until.dart';

class JudgingScheduleTimer extends StatelessWidget {
  final bool live;
  final TextStyle? positiveStyle;
  final TextStyle? negativeStyle;

  const JudgingScheduleTimer({
    Key? key,
    this.live = false,
    this.positiveStyle,
    this.negativeStyle,
  }) : super(key: key);

  TmsDateTime getNextScheduledTime(List<JudgingSession> sessions) {
    // sort sessions by time
    List<JudgingSession> sortedSessions = sortJudgingSessionsByTime(sessions);

    if (live) {
      // find the first session that is not completed
      for (JudgingSession session in sortedSessions) {
        if (!session.completed) {
          return session.startTime;
        }
      }
    } else {
      // find the first session that is ahead of current time
      for (JudgingSession session in sortedSessions) {
        DateTime startTime = tmsDateTimeToDateTime(session.startTime);
        if (startTime.isAfter(DateTime.now())) {
          return session.startTime;
        }
      }
    }

    return TmsDateTime();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<JudgingSessionProvider, List<JudgingSession>>(
      selector: (_, provider) => provider.judgingSessions,
      builder: (context, sessions, _) {
        return TimeUntil(
          time: getNextScheduledTime(sessions),
          positiveStyle: positiveStyle,
          negativeStyle: negativeStyle,
        );
      },
    );
  }
}
