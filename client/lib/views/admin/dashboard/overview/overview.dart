import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/event_local_db.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/overview/event_overview/event_overview.dart';
import 'package:tms/views/admin/dashboard/overview/info_banner.dart';
import 'package:tms/views/admin/dashboard/overview/scoring/scoring_overview.dart';

class Overview extends StatefulWidget {
  const Overview({Key? key}) : super(key: key);

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  // value notifiers
  final ValueNotifier<Event> _eventNotifier = ValueNotifier<Event>(EventLocalDB.singleDefault());
  final ValueNotifier<List<Team>> _teamsNotifier = ValueNotifier<List<Team>>([]);
  final ValueNotifier<List<GameMatch>> _matchesNotifier = ValueNotifier<List<GameMatch>>([]);
  final ValueNotifier<List<JudgingSession>> _judgingSessionsNotifier = ValueNotifier<List<JudgingSession>>([]);

  // set value notifiers
  set _setEvent(Event event) {
    _eventNotifier.value = event;
  }

  set _setTeams(List<Team> teams) {
    _teamsNotifier.value = teams;
  }

  set _setMatches(List<GameMatch> matches) {
    _matchesNotifier.value = matches;
  }

  set _setJudgingSessions(List<JudgingSession> sessions) {
    _judgingSessionsNotifier.value = sessions;
  }

  void _setData() {
    getEvent().then((e) => _setEvent = e);
    getMatches().then((m) => _setMatches = m);
    getJudgingSessions().then((s) => _setJudgingSessions = s);
    getTeams().then((t) => _setTeams = t);
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      _setData();
    });
    onEventUpdate((e) => _setEvent = e);
    onMatchesUpdate((m) => _setMatches = m);
    onJudgingSessionsUpdate((s) => _setJudgingSessions = s);
    onTeamsUpdate((t) => _setTeams = t);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppTheme.isDarkThemeNotifier,
      builder: (context, v, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                SizedBox(
                  height: 50,
                  width: constraints.maxWidth,
                  child: OverviewInfoBanner(
                    matchNotifier: _matchesNotifier,
                    judgingSessionsNotifier: _judgingSessionsNotifier,
                    teamsNotifier: _teamsNotifier,
                  ),
                ),
                SizedBox(
                  height: constraints.maxHeight - 50,
                  width: constraints.maxWidth,
                  child: Row(
                    children: [
                      SizedBox(
                        width: constraints.maxWidth * 0.65,
                        child: EventOverview(
                          eventNotifier: _eventNotifier,
                          teamsNotifier: _teamsNotifier,
                          matchesNotifier: _matchesNotifier,
                          judgingSessionsNotifier: _judgingSessionsNotifier,
                        ),
                      ),
                      SizedBox(
                        width: constraints.maxWidth * 0.35,
                        child: ScoringOverview(teamsNotifier: _teamsNotifier),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
