import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/overview/event_overview/timers/judging_timers.dart';
import 'package:tms/views/admin/dashboard/overview/event_overview/timers/main_timer.dart';
import 'package:tms/views/admin/dashboard/overview/event_overview/timers/match_timers.dart';

class Timers extends StatelessWidget {
  final ValueNotifier<List<GameMatch>> matchesNotifier;
  final ValueNotifier<List<JudgingSession>> judgingSessionsNotifier;

  const Timers({
    Key? key,
    required this.matchesNotifier,
    required this.judgingSessionsNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? fontSize = Responsive.isDesktop(context) ? 40 : 30;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Container(
              height: constraints.maxHeight / 3,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
              child: ValueListenableBuilder(
                valueListenable: matchesNotifier,
                builder: (context, List<GameMatch> matches, _) {
                  return MatchTimers(
                    matches: matches,
                    fontSize: fontSize,
                  );
                },
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
              height: constraints.maxHeight / 3,
              child: ValueListenableBuilder(
                valueListenable: judgingSessionsNotifier,
                builder: (context, List<JudgingSession> sessions, _) {
                  return JudgingTimers(
                    judgingSessions: sessions,
                    fontSize: fontSize,
                  );
                },
              ),
            ),
            SizedBox(
              height: constraints.maxHeight / 3,
              child: MainTimer(
                fontSize: fontSize,
              ),
            ),
          ],
        );
      },
    );
  }
}
