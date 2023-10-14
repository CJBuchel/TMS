// generic info banner which holds number of matches completed, number of session, warnings and errors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/requests/team_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/checks/team_errors.dart';
import 'package:tms/views/shared/checks/team_warnings.dart';

class TeamInfoBanner extends StatefulWidget {
  final String teamNumber;
  const TeamInfoBanner({
    Key? key,
    required this.teamNumber,
  }) : super(key: key);

  @override
  State<TeamInfoBanner> createState() => _TeamInfoBannerState();
}

class _TeamInfoBannerState extends State<TeamInfoBanner> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  Team _team = LocalDatabaseMixin.teamDefault();
  Event? _event;
  List<GameMatch> _matches = [];
  List<JudgingSession> _sessions = [];

  set _setTeam(Team t) {
    if (mounted) {
      setState(() {
        _team = t;
      });
    }
  }

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

  set _setMatch(GameMatch m) {
    // find match if exists
    final index = _matches.indexWhere((match) => match.matchNumber == m.matchNumber);
    if (index != -1) {
      if (mounted) {
        setState(() {
          _matches[index] = m;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _matches.add(m);
        });
      }
    }
  }

  set _setSessions(List<JudgingSession> s) {
    if (mounted) {
      setState(() {
        _sessions = s;
      });
    }
  }

  set _setSession(JudgingSession s) {
    // find session if exists
    final index = _sessions.indexWhere((session) => session.sessionNumber == s.sessionNumber);
    if (index != -1) {
      if (mounted) {
        setState(() {
          _sessions[index] = s;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _sessions.add(s);
        });
      }
    }
  }

  void fetchTeam() {
    getTeamRequest(widget.teamNumber).then((res) {
      if (res.item1 == HttpStatus.ok) {
        if (res.item2 != null) {
          _setTeam = res.item2!;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    onEventUpdate((e) => _setEvent = e);
    onTeamUpdate((t) => _setTeam = t);
    onMatchUpdate((m) => _setMatch = m);
    onMatchesUpdate((m) => _setMatches = m);
    onJudgingSessionUpdate((s) => _setSession = s);
    onJudgingSessionsUpdate((s) => _setSessions = s);
    fetchTeam();
  }

  Widget _completedRounds() {
    int totalRounds = 0;
    int completedRounds = 0;
    for (var match in _matches) {
      for (var table in match.matchTables) {
        if (table.teamNumber == _team.teamNumber) {
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
        if (pod.teamNumber == _team.teamNumber) {
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
          team: _team,
          event: _event,
        ),
        SingleTeamErrors(
          team: _team,
          event: _event,
        ),
      ],
    );
  }
}
