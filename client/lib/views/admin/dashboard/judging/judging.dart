import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/requests/judging_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/judging/judging_edit_table.dart';
import 'package:tms/views/admin/dashboard/judging/judging_info.dart';
import 'package:tms/views/shared/network_error_popup.dart';
import 'package:tms/utils/sorter_util.dart';

class Judging extends StatefulWidget {
  const Judging({Key? key}) : super(key: key);

  @override
  State<Judging> createState() => _JudgingState();
}

class _JudgingState extends State<Judging> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  List<GameMatch> _matches = [];
  List<JudgingSession> _sessions = [];
  List<Team> _teams = [];
  Event? _event;

  set setMatches(List<GameMatch> matches) {
    if (mounted) {
      matches = sortMatchesByTime(matches);
      setState(() {
        _matches = matches;
      });
    }
  }

  set setMatch(GameMatch match) {
    if (mounted) {
      // find match if exists
      final index = _matches.indexWhere((m) => m.matchNumber == match.matchNumber);
      if (index != -1) {
        setState(() {
          _matches[index] = match;
        });
      } else {
        setState(() {
          _matches.add(match);
        });
      }
    }
  }

  set setTeams(List<Team> teams) {
    if (mounted) {
      setState(() {
        _teams = teams;
      });
    }
  }

  set setTeam(Team team) {
    if (mounted) {
      // find team if exists
      final index = _teams.indexWhere((t) => t.teamNumber == team.teamNumber);
      if (index != -1) {
        setState(() {
          _teams[index] = team;
        });
      } else {
        setState(() {
          _teams.add(team);
        });
      }
    }
  }

  set setJudgingSessions(List<JudgingSession> sessions) {
    if (mounted) {
      sessions = sortJudgingByTime(sessions);
      setState(() {
        _sessions = sessions;
      });
    }
  }

  set setJudgingSession(JudgingSession session) {
    if (mounted) {
      // find session if exists
      final index = _sessions.indexWhere((s) => s.sessionNumber == session.sessionNumber);
      if (index != -1) {
        setState(() {
          _sessions[index] = session;
        });
      } else {
        setState(() {
          _sessions.add(session);
        });
      }
    }
  }

  set setEvent(Event event) {
    if (mounted) {
      setState(() {
        _event = event;
      });
    }
  }

  void fetchJudging() {
    getJudgingSessionsRequest().then((value) {
      if (value.item1 == HttpStatus.ok) {
        setJudgingSessions = value.item2;
      } else {
        showNetworkError(value.item1, context, subMessage: "Error fetching judging sessions");
      }
    });
  }

  @override
  void initState() {
    super.initState();

    onEventUpdate((e) => setEvent = e);

    // live setters
    onMatchUpdate((m) => setMatch = m);
    onMatchesUpdate((m) => setMatches = m);
    onTeamUpdate((t) => setTeam = t);
    onTeamsUpdate((t) => setTeams = t);
    onJudgingSessionUpdate((s) => setJudgingSession = s);
    onJudgingSessionsUpdate((s) => setJudgingSessions = s);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((context, constraints) {
        return Column(
          children: [
            Container(
              height: 100,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
              ),
              child: JudgingInfo(
                matches: _matches,
                teams: _teams,
                judgingSessions: _sessions,
                event: _event,
              ),
            ),

            // table section
            Expanded(
              child: JudgingEditTable(
                sessions: _sessions,
                teams: _teams,
                requestJudgingSessions: () => fetchJudging(),
              ),
            ),
          ],
        );
      }),
    );
  }
}
