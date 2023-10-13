import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/checks/judging_errors.dart';
import 'package:tms/views/shared/checks/judging_warnings.dart';
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

  Widget judgingProgress() {
    int completedJudgingSessions = judgingSessions.asMap().entries.where((e) => e.value.complete).length;

    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 10),
          child: Icon(Icons.check, color: Colors.green),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            '$completedJudgingSessions/${judgingSessions.length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          JudgingTTLClock(
            sessions: judgingSessions,
            showOnlyClock: true,
            autoFontSize: false,
          ),
          judgingProgress(),

          // warning system
          JudgingWarnings(
            matches: matches,
            teams: teams,
            judgingSessions: judgingSessions,
            event: event,
          ),

          // error system
          JudgingErrors(
            matches: matches,
            teams: teams,
            judgingSessions: judgingSessions,
            event: event,
          ),
        ],
      );
    });
  }
}
