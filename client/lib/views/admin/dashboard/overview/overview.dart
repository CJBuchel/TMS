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

  Color _borderColor = AppTheme.isDarkTheme ? Colors.white : Colors.black;

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
    getTeams().then((t) => _setTeams = t);
    getMatches().then((m) => _setMatches = m);
    getJudgingSessions().then((s) => _setJudgingSessions = s);
  }

  void _setThemeColor() {
    setState(() {
      _borderColor = AppTheme.isDarkTheme ? Colors.white : Colors.black;
    });
  }

  @override
  void initState() {
    super.initState();
    _setData();
    onEventUpdate((e) => _setEvent = e);
    onTeamsUpdate((t) => _setTeams = t);
    onMatchesUpdate((m) => _setMatches = m);
    onJudgingSessionsUpdate((s) => _setJudgingSessions = s);
    _setThemeColor();

    AppTheme.isDarkThemeNotifier.addListener(_setThemeColor);
  }

  @override
  void dispose() {
    AppTheme.isDarkThemeNotifier.removeListener(_setThemeColor);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          SizedBox(
            height: 50,
            width: constraints.maxWidth,
            child: const OverviewInfoBanner(),
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
    });
  }
}
