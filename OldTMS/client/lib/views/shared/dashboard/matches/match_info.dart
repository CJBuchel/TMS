import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/checks/match_errors.dart';
import 'package:tms/views/shared/checks/match_warnings.dart';
import 'package:tms/views/shared/clocks/match_ttl_clock.dart';

class MatchInfo extends StatelessWidget {
  final List<GameMatch> matches;
  final List<Team> teams;
  final List<JudgingSession> judgingSessions;
  final Event? event;

  const MatchInfo({
    Key? key,
    required this.matches,
    required this.teams,
    required this.event,
    required this.judgingSessions,
  }) : super(key: key);

  Widget matchProgress() {
    int completedMatches = matches.asMap().entries.where((e) => e.value.complete).length;
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 10),
          child: Icon(Icons.check, color: Colors.green),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            '$completedMatches/${matches.length}',
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
        // Match progress
        // team errors
        children: [
          MatchTTLClock(
            matches: matches,
            showOnlyClock: true,
            autoFontSize: false,
            live: true,
          ),
          matchProgress(),

          // warning system
          MatchWarnings(
            matches: matches,
            teams: teams,
            event: event,
            judgingSessions: judgingSessions,
          ),

          // error system
          MatchErrors(
            matches: matches,
            teams: teams,
            event: event,
          ),
        ],
      );
    });
  }
}
