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

  const _JudgingScheduleTimer({
    Key? key,
    this.positiveStyle,
    this.negativeStyle,
    required this.sessions,
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

    // find the next sessions that is ahead of current time
    int diff = 0;
    for (JudgingSession session in sessions) {
      DateTime startTime = tmsDateTimeToDateTime(session.startTime);
      if (startTime.isAfter(DateTime.now())) {
        diff = tmsDateTimeGetDifferenceFromNow(session.startTime);
        break;
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
      builder: (context, difference, _) {
        String stringTime = secondsToTimeString(difference);
        TextStyle style = difference > 0 ? widget.positiveStyle! : widget.negativeStyle!;
        return Text(
          difference > 0 ? "+$stringTime" : "-$stringTime",
          style: style,
        );
      },
    );
  }
}

class JudgingScheduleTimer extends StatelessWidget {
  final TextStyle? positiveStyle;
  final TextStyle? negativeStyle;

  const JudgingScheduleTimer({
    Key? key,
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
        );
      },
    );
  }
}
