import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/matches/checks/errors.dart';
import 'package:tms/views/admin/dashboard/matches/checks/warnings.dart';
import 'package:tms/views/match_control/ttl_clock.dart';

class Info extends StatelessWidget {
  final List<GameMatch> matches;
  final List<Team> teams;
  final List<JudgingSession> judgingSessions;
  final Event? event;
  final Function(List<MatchError>)? onErrors;
  final Function(List<MatchWarning>)? onWarnings;

  const Info({
    Key? key,
    required this.matches,
    required this.teams,
    required this.event,
    required this.judgingSessions,
    this.onErrors,
    this.onWarnings,
  }) : super(key: key);

  Widget matchProgress(double? fontSize) {
    int completedMatches = matches.asMap().entries.where((e) => e.value.complete).length;
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Icon(Icons.check, color: Colors.green, size: fontSize),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            '$completedMatches/${matches.length}',
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

    return LayoutBuilder(builder: ((context, constraints) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        // Match progress
        // team errors
        children: [
          TTLClock(matches: matches, fontSize: fontSize, showOnlyClock: true),
          matchProgress(fontSize),

          // warning system
          MatchWarnings(
            matches: matches,
            teams: teams,
            event: event,
            judgingSessions: judgingSessions,
            fontSize: fontSize,
            onWarnings: onWarnings,
          ),

          // error system
          MatchErrors(
            matches: matches,
            teams: teams,
            event: event,
            fontSize: fontSize,
            onErrors: onErrors,
          ),
        ],
      );
    }));
  }
}