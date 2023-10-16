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

  set setTeams(List<Team> teams) {
    if (mounted) {
      setState(() {
        _teams = teams;
      });
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

  void setData() {
    getEvent().then((e) => setEvent = e);
    getMatches().then((m) => setMatches = m);
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
      builder: ((context, constraints) {
        return Column(
          children: [
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
