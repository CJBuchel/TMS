// generic info banner which holds number of matches completed, number of session, warnings and errors

import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/checks/team_errors.dart';
import 'package:tms/views/shared/checks/team_warnings.dart';

class TeamInfoBanner extends StatefulWidget {
  final Team team;
  const TeamInfoBanner({
    Key? key,
    required this.team,
  }) : super(key: key);

  @override
  State<TeamInfoBanner> createState() => _TeamInfoBannerState();
}

class _TeamInfoBannerState extends State<TeamInfoBanner> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  // Team _team = TeamsLocalDB.singleDefault();
  Event? _event;
  List<GameMatch> _matches = [];
  List<JudgingSession> _sessions = [];

  set _setEvent(Event e) {
    if (mounted) {
      setState(() {
        _event = e;
      });
    }
  }

  set _setMatches(List<GameMatch> m) {
    if (mounted) {
      setState(() {
        _matches = m;
      });
    }
  }

  set _setSessions(List<JudgingSession> s) {
    if (mounted) {
      setState(() {
        _sessions = s;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    onEventUpdate((e) => _setEvent = e);
    onMatchesUpdate((m) => _setMatches = m);
    onJudgingSessionsUpdate((s) => _setSessions = s);
  }

  Widget _completedRounds() {
    int totalRounds = 0;
    int completedRounds = 0;
    for (var match in _matches) {
      for (var table in match.matchTables) {
        if (table.teamNumber == widget.team.teamNumber) {
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

    for (var session in _sessions) {
      for (var pod in session.judgingPods) {
        if (pod.teamNumber == widget.team.teamNumber) {
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
          team: widget.team,
          event: _event,
        ),
        SingleTeamErrors(
          team: widget.team,
          event: _event,
        ),
      ],
    );
  }
}
