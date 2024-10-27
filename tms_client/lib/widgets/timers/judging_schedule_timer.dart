import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/judging_session.dart';
import 'package:tms/providers/judging_session_provider.dart';
import 'package:tms/utils/sorter_util.dart';
import 'package:tms/utils/tms_time_utils.dart';

class _JudgingScheduleTimer extends StatefulWidget {
  final TextStyle? positiveStyle;
  final TextStyle? negativeStyle;
  final List<JudgingSession> sessions;
  final bool live;

  const _JudgingScheduleTimer({
    Key? key,
    this.positiveStyle,
    this.negativeStyle,
    required this.sessions,
    required this.live,
  }) : super(key: key);

  @override
  _JudgingScheduleTimerState createState() => _JudgingScheduleTimerState();
}

class _JudgingScheduleTimerState extends State<_JudgingScheduleTimer> {
  Timer? _timer;
  ValueNotifier<int> _difference = ValueNotifier<int>(0);

  Future<int> getTimeDifference() async {
    // list of sessions
    List<JudgingSession> sessions = sortJudgingSessionsByTime(widget.sessions);

    int diff = 0;
    if (widget.live) {
      // find the first session that is not completed
      for (JudgingSession session in sessions) {
        if (!session.completed) {
          diff = tmsDateTimeGetDifferenceFromNow(session.startTime);
          break;
        }
      }
    } else {
      // find the first session that is ahead of current time
      for (JudgingSession session in sessions) {
        DateTime startTime = tmsDateTimeToDateTime(session.startTime);
        if (startTime.isAfter(DateTime.now())) {
          diff = tmsDateTimeGetDifferenceFromNow(session.startTime);
          break;
        }
      }
    }

    return diff;
  }

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      getTimeDifference().then((value) {
        _difference.value = value;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _difference,
      builder: (context, diff, _) {
        String stringTime = secondsToTimeString(diff);
        return Text(
          diff < 0 ? "-$stringTime" : "+$stringTime",
          style: diff > 0 ? widget.positiveStyle : widget.negativeStyle,
        );
      },
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    return Selector<JudgingSessionProvider, List<JudgingSession>>(
      selector: (_, provider) => provider.judgingSessions,
      builder: (context, sessions, _) {
        return _JudgingScheduleTimer(
          positiveStyle: positiveStyle,
          negativeStyle: negativeStyle,
          sessions: sessions,
          live: live,
        );
      },
    );
  }
}
