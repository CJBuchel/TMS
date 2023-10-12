import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/judging/checks/errors.dart';
import 'package:tms/views/admin/dashboard/judging/checks/warnings.dart';
import 'package:tms/views/shared/judging_ttl_clock.dart';

class JudgingInfo extends StatelessWidget {
  final List<GameMatch> matches;
  final List<Team> teams;
  final List<JudgingSession> judgingSessions;
  final Event? event;

  const JudgingInfo({
    Key? key,
    required this.matches,
    required this.teams,
    required this.judgingSessions,
    required this.event,
  }) : super(key: key);

  Widget judgingProgress(double? fontSize) {
    int completedJudgingSessions = judgingSessions.asMap().entries.where((e) => e.value.complete).length;

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Icon(Icons.check, color: Colors.green, size: fontSize),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            '$completedJudgingSessions/${judgingSessions.length}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double? fontSize = Responsive.isDesktop(context)
        ? 24
        : Responsive.isTablet(context)
            ? 20
            : 16;
    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          JudgingTTLClock(sessions: judgingSessions, fontSize: fontSize, showOnlyClock: true),
          judgingProgress(fontSize),

          // warning system
          JudgingWarnings(
            matches: matches,
            teams: teams,
            judgingSessions: judgingSessions,
            event: event,
            fontSize: fontSize,
          ),

          // error system
          JudgingErrors(
            matches: matches,
            teams: teams,
            judgingSessions: judgingSessions,
            event: event,
            fontSize: fontSize,
          ),
        ],
      );
    });
  }
}
