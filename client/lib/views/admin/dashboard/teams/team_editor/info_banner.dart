// generic info banner which holds number of matches completed, number of session, warnings and errors

import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/checks/team_errors.dart';
import 'package:tms/views/shared/checks/team_warnings.dart';

class TeamInfoBanner extends StatelessWidget {
  final Team team;
  final Event? event;
  final List<JudgingSession> sessions;
  final List<GameMatch> matches;

  const TeamInfoBanner({
    Key? key,
    required this.team,
    required this.event,
    required this.sessions,
    required this.matches,
  }) : super(key: key);

  Widget _completedRounds() {
    int totalRounds = 0;
    int completedRounds = 0;
    for (var match in matches) {
      for (var table in match.matchTables) {
        if (table.teamNumber == team.teamNumber) {
          totalRounds += 1;
          completedRounds += match.complete ? 1 : 0;
        }
      }
    }

    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 10),
          child: Icon(Icons.check, color: Colors.green),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            'Matches: $completedRounds/$totalRounds',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _completedSessions() {
    int totalSessions = 0;
    int completedSessions = 0;

    for (var session in sessions) {
      for (var pod in session.judgingPods) {
        if (pod.teamNumber == team.teamNumber) {
          totalSessions += 1;
          completedSessions += session.complete ? 1 : 0;
        }
      }
    }

    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 10),
          child: Icon(Icons.check, color: Colors.green),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            'Sessions: $completedSessions/$totalSessions',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _completedRounds(),
        _completedSessions(),
        SingleTeamWarnings(
          team: team,
          event: event,
        ),
        SingleTeamErrors(
          team: team,
          event: event,
        ),
      ],
    );
  }
}
