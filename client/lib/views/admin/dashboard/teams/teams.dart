import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/requests/team_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/teams/team_editor/team_editor.dart';
import 'package:tms/views/admin/dashboard/teams/team_select/team_select.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class Teams extends StatefulWidget {
  const Teams({Key? key}) : super(key: key);

  @override
  State<Teams> createState() => _TeamsState();
}

class _TeamsState extends State<Teams> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  List<Team> _teams = [];
  List<JudgingSession> _sessions = [];
  List<GameMatch> _matches = [];
  Event? _event;
  Team? _selectedTeam;

  set setTeams(List<Team> value) {
    if (mounted) {
      setState(() {
        _teams = value;
      });
    }
  }

  set setTeam(Team value) {
    if (mounted) {
      // find team if exists
      final index = _teams.indexWhere((t) => t.teamNumber == value.teamNumber);
      if (index != -1) {
        if (_selectedTeam?.teamNumber == value.teamNumber) {
          setSelectedTeam = value;
        }
        setState(() {
          _teams[index] = value;
        });
      } else {
        setState(() {
          _teams.add(value);
        });
      }
    }
  }

  set setSelectedTeam(Team? value) {
    if (mounted) {
      setState(() {
        _selectedTeam = value;
      });
    }
  }

  void setJudgingSessions(List<JudgingSession> sessions) {
    if (mounted) {
      setState(() {
        _sessions = sessions;
      });
    }
  }

  void setJudgingSession(JudgingSession session) {
    if (mounted) {
      setState(() {
        final index = _sessions.indexWhere((s) => s.sessionNumber == session.sessionNumber);
        if (index != -1) {
          _sessions[index] = session;
        } else {
          _sessions.add(session);
        }
      });
    }
  }

  void setMatches(List<GameMatch> matches) {
    if (mounted) {
      setState(() {
        _matches = matches;
      });
    }
  }

  void setMatch(GameMatch match) {
    if (mounted) {
      setState(() {
        final index = _matches.indexWhere((m) => m.matchNumber == match.matchNumber);
        if (index != -1) {
          _matches[index] = match;
        } else {
          _matches.add(match);
        }
      });
    }
  }

  void setEvent(Event event) {
    if (mounted) {
      setState(() {
        _event = event;
      });
    }
  }

  void fetchTeams() {
    getTeamsRequest().then((value) {
      if (value.item1 != HttpStatus.ok) {
        showNetworkError(value.item1, context, subMessage: "Failed to fetch teams");
      } else {
        setTeams = value.item2;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    onTeamsUpdate((teams) => setTeams = teams);
    onTeamUpdate((team) => setTeam = team);
    onJudgingSessionsUpdate((s) => setJudgingSessions(s));
    onJudgingSessionUpdate((s) => setJudgingSession(s));
    onMatchesUpdate((m) => setMatches(m));
    onMatchUpdate((m) => setMatch(m));
    onEventUpdate((e) => setEvent(e));
  }

  Widget getTeamEditor() {
    if (_selectedTeam != null) {
      return TeamEditor(
        team: _selectedTeam!,
        event: _event,
        sessions: _sessions,
        matches: _matches,
      );
    } else {
      return const Center(
        child: Text(
          'No Team Selected',
          style: TextStyle(fontSize: 25),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            // team selector list (left side)
            Container(
              height: constraints.maxHeight,
              width: constraints.maxWidth * 0.3, // 30%

              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: AppTheme.isDarkTheme ? Colors.white : Colors.black,
                    width: 1,
                  ),
                ),
              ),

              child: TeamSelect(
                event: _event,
                teams: _teams,
                onTeamSelected: (t) => setSelectedTeam = t,
                requestTeams: () => fetchTeams(),
              ),
            ),

            // team edit (right side)
            Expanded(
              child: getTeamEditor(),
            ),
          ],
        );
      },
    );
  }
}
