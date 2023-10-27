import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/sorter_util.dart';
import 'package:tms/views/judge_advisor/event_information/event_information.dart';
import 'package:tms/views/judge_advisor/judging_sessions/judging_sessions.dart';

class JAHandler extends StatefulWidget {
  const JAHandler({Key? key}) : super(key: key);

  @override
  State<JAHandler> createState() => _JAHandlerState();
}

class _JAHandlerState extends State<JAHandler> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  final ValueNotifier<List<Team>> _teams = ValueNotifier([]);
  final ValueNotifier<List<JudgingSession>> _sessions = ValueNotifier([]);
  final ValueNotifier<List<GameMatch>> _matches = ValueNotifier([]);

  set _setMatches(List<GameMatch> matches) {
    _matches.value = matches;
  }

  set _setTeams(List<Team> teams) {
    _teams.value = teams;
  }

  set _setSessions(List<JudgingSession> sessions) {
    sessions = sortJudgingByTime(sessions);
    if (_sessions.value.length != sessions.length) {
      setState(() {
        _sessions.value = sessions;
      });
    } else {
      // check if any of the sessions have changed
      for (JudgingSession session in sessions) {
        for (JudgingSession currentSession in _sessions.value) {
          if (session.sessionNumber == currentSession.sessionNumber) {
            if (session.complete != currentSession.complete) {
              setState(() {
                _sessions.value = sessions;
              });
            }
          }
        }
      }

      _sessions.value = sessions;
    }
  }

  @override
  void initState() {
    super.initState();

    onTeamsUpdate((t) => _setTeams = t);
    onJudgingSessionsUpdate((s) => _setSessions = s);
    onMatchesUpdate((m) => _setMatches = m);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        height: constraints.maxHeight,
        width: constraints.maxWidth,
        child: Row(
          children: [
            // left side
            Expanded(
              flex: 1,
              child: EventInformation(
                matches: _matches,
                sessions: _sessions,
              ),
            ),

            // right side (judging sessions table)
            Expanded(
              flex: 1,
              child: JudgingSessions(
                teams: _teams,
                judgingSessions: _sessions,
              ),
            ),
          ],
        ),
      );
    });
  }
}
