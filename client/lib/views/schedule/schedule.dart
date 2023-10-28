import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/schedule/schedule_handler.dart';
import 'package:tms/views/shared/tool_bar.dart';

class Schedule extends StatefulWidget {
  const Schedule({Key? key}) : super(key: key);

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  final List<Team> _teams = [];
  final List<GameMatch> _matches = [];
  final List<JudgingSession> _sessions = [];

  set _setTeams(List<Team> teams) {
    if (mounted) {
      setState(() {
        _teams.clear();
        _teams.addAll(teams);
      });
    }
  }

  set _setMatches(List<GameMatch> matches) {
    if (mounted) {
      setState(() {
        _matches.clear();
        _matches.addAll(matches);
      });
    }
  }

  set _setSessions(List<JudgingSession> sessions) {
    if (mounted) {
      setState(() {
        _sessions.clear();
        _sessions.addAll(sessions);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    onTeamsUpdate((t) => _setTeams = t);
    onMatchesUpdate((m) => _setMatches = m);
    onJudgingSessionsUpdate((s) => _setSessions = s);

    getMatches().then((m) => _setMatches = m);
    getJudgingSessions().then((s) => _setSessions = s);
    getTeams().then((t) => _setTeams = t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TmsToolBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ValueListenableBuilder(
            valueListenable: AppTheme.isDarkThemeNotifier,
            builder: (context, v, _) {
              return SizedBox(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                child: ScheduleHandler(teams: _teams, matches: _matches, sessions: _sessions),
              );
            },
          );
        },
      ),
    );
  }
}
