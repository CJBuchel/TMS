import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/requests/match_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/dashboard/matches/match_info.dart';
import 'package:tms/views/shared/dashboard/matches/match_edit_table.dart';
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

  set setTeams(List<Team> teams) {
    if (mounted) {
      setState(() {
        _teams = teams;
      });
    }
  }

  set setJudgingSessions(List<JudgingSession> sessions) {
    if (mounted) {
      setState(() {
        _judgingSessions = sessions;
      });
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

  void setData() {
    getEvent().then((e) => setEvent = e);
    fetchMatches();
    getTeams().then((t) => setTeams = t);
    getJudgingSessions().then((s) => setJudgingSessions = s);
  }

  @override
  void initState() {
    super.initState();
    setData();

    // live setters
    onEventUpdate((e) => setEvent = e);
    onMatchesUpdate((m) => setMatches = m);
    onTeamsUpdate((t) => setTeams = t);
    onJudgingSessionsUpdate((s) => setJudgingSessions = s);
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
