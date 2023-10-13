import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/requests/match_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/matches/match_info.dart';
import 'package:tms/views/admin/dashboard/matches/match_edit_table.dart';
import 'package:tms/views/shared/network_error_popup.dart';
import 'package:tms/utils/sorter_util.dart';

class Matches extends StatefulWidget {
  const Matches({Key? key}) : super(key: key);

  @override
  State<Matches> createState() => _MatchesState();
}

class _MatchesState extends State<Matches> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  List<GameMatch> _matches = [];
  List<Team> _teams = [];
  List<JudgingSession> _judgingSessions = [];
  Event? _event;

  set setMatches(List<GameMatch> value) {
    if (mounted) {
      value = sortMatchesByTime(value);
      setState(() {
        _matches = value;
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
      setState(() {
        _judgingSessions = sessions;
      });
    }
  }

  set setJudgingSession(JudgingSession session) {
    if (mounted) {
      // find session if exists
      final index = _judgingSessions.indexWhere((s) => s.sessionNumber == session.sessionNumber);
      if (index != -1) {
        setState(() {
          _judgingSessions[index] = session;
        });
      } else {
        setState(() {
          _judgingSessions.add(session);
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

  void fetchMatches() {
    getMatchesRequest().then((value) {
      if (value.item1 == HttpStatus.ok) {
        setMatches = value.item2;
      } else {
        showNetworkError(value.item1, context, subMessage: "Error fetching matches");
      }
    });
  }

  @override
  void initState() {
    super.initState();

    onEventUpdate((e) => setEvent = e);

    // live setters
    onMatchesUpdate((m) => setMatches = m);
    onMatchUpdate((m) => setMatch = m);
    onTeamsUpdate((t) => setTeams = t);
    onTeamUpdate((t) => setTeam = t);
    onJudgingSessionsUpdate((s) => setJudgingSessions = s);
    onJudgingSessionUpdate((s) => setJudgingSession = s);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // info section
            Container(
              height: 50,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
              ),
              child: MatchInfo(
                matches: _matches,
                teams: _teams,
                judgingSessions: _judgingSessions,
                event: _event,
              ),
            ),

            // table section
            Expanded(
              child: MatchEditTable(
                matches: _matches,
                teams: _teams,
                requestMatches: () => fetchMatches(),
              ),
            ),
          ],
        );
      },
    );
  }
}
