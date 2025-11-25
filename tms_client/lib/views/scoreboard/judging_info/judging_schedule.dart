import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/judging_session.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/utils/sorter_util.dart';
import 'package:tms/utils/tms_time_utils.dart';
import 'package:tms/views/scoreboard/judging_info/next_judging_session_row.dart';
import 'package:tms/widgets/timers/judging_schedule_timer.dart';

class JudgingSchedule extends StatefulWidget {
  final List<JudgingSession> judgingSessions;

  const JudgingSchedule({Key? key, required this.judgingSessions})
      : super(key: key);

  @override
  _JudgingInfoState createState() => _JudgingInfoState();
}

class _JudgingInfoState extends State<JudgingSchedule> {
  List<JudgingSession> _futureJudgingSessions = [];
  Timer? _sessionCheckerTimer;

  void setFutureJudgingSessions() {
    List<JudgingSession> futureJudgingSessions = [];
    for (var session in widget.judgingSessions) {
      DateTime endTime = tmsDateTimeToDateTime(session.endTime);
      if (endTime.isAfter(DateTime.now())) {
        futureJudgingSessions.add(session);
      }
    }

    futureJudgingSessions = sortJudgingSessionsByTime(futureJudgingSessions);
    if (mounted && !listEquals(_futureJudgingSessions, futureJudgingSessions)) {
      setState(() {
        _futureJudgingSessions = futureJudgingSessions;
      });
    }
  }

  @override
  void didUpdateWidget(covariant JudgingSchedule oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.judgingSessions, widget.judgingSessions)) {
      setFutureJudgingSessions();
    }
  }

  @override
  void initState() {
    super.initState();
    setFutureJudgingSessions();
    _sessionCheckerTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setFutureJudgingSessions();
    });
  }

  @override
  void dispose() {
    _sessionCheckerTimer?.cancel();
    super.dispose();
  }

  Widget _headerRow(
      BuildContext context, List<JudgingSession> futureJudgingSessions) {
    Color? evenDarkBackground = const Color(0xFF1B6A92);
    Color? oddDarkBackground = const Color(0xFF27A07A);

    Color? evenLightBackground = const Color(0xFF9CDEFF);
    Color? oddLightBackground = const Color(0xFF81FFD7);

    Color? evenBackground = Theme.of(context).brightness == Brightness.light
        ? evenLightBackground
        : evenDarkBackground;
    Color? oddBackground = Theme.of(context).brightness == Brightness.light
        ? oddLightBackground
        : oddDarkBackground;

    JudgingSession? nextSession = futureJudgingSessions.firstOrNull;

    return Container(
      height: 40,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: oddBackground,
              child: const Center(
                child: Text(
                  "Judging Schedule",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: evenBackground,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Next: #${nextSession?.sessionNumber} (",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const JudgingScheduleTimer(
                      live: false,
                      positiveStyle: TextStyle(fontWeight: FontWeight.bold),
                      negativeStyle: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const Text(")"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleList(BuildContext context) {
    Color? evenLightBackground = Theme.of(context).scaffoldBackgroundColor;
    Color? oddLightBackground = Theme.of(context).cardColor;

    Color? evenDarkBackground = Theme.of(context).scaffoldBackgroundColor;
    Color? oddDarkBackground =
        lighten(Theme.of(context).scaffoldBackgroundColor, 0.05);

    Color? evenBackground = Theme.of(context).brightness == Brightness.light
        ? evenLightBackground
        : evenDarkBackground;
    Color? oddBackground = Theme.of(context).brightness == Brightness.light
        ? oddLightBackground
        : oddDarkBackground;

    return Selector<TmsLocalStorageProvider, bool>(
      selector: (_, provider) => provider.scoreboardShowJudgingInfo,
      builder: (context, show, _) {
        if (show) {
          return Container(
            height: 160, // 3*40, then + 40 for header
            child: Column(
              children: [
                _headerRow(context, _futureJudgingSessions),
                // generate rows for each match
                ...List<Widget>.generate(_futureJudgingSessions.length,
                    (index) {
                  return Container(
                    height: 40,
                    color: index % 2 == 0 ? evenBackground : oddBackground,
                    child: NextJudgingSessionRow(
                      nextSession: _futureJudgingSessions[index],
                      index: index,
                    ),
                  );
                }).take(3),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_futureJudgingSessions.isEmpty) {
      return const SizedBox.shrink();
    } else {
      return _scheduleList(context);
    }
  }
}
