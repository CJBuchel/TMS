import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/network/network.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/scoreboard/judge_info.dart';
import 'package:tms/views/scoreboard/match_info.dart';
import 'package:tms/views/scoreboard/team_table.dart';
import 'package:tms/views/shared/tool_bar.dart';

class ScoreboardUtil {
  static final Future<SharedPreferences> _localStorage = SharedPreferences.getInstance();

  static Future<void> setAlwaysMatchSchedule(bool alwaysMatchSchedule) async {
    await _localStorage.then((value) => value.setBool(storeScoreboardAlwaysMatchSchedule, alwaysMatchSchedule));
  }

  static Future<bool> getAlwaysMatchSchedule() async {
    try {
      var alwaysMatchSchedule = await _localStorage.then((value) => value.getBool(storeScoreboardAlwaysMatchSchedule));
      if (alwaysMatchSchedule != null) {
        return alwaysMatchSchedule;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<void> setAlwaysJudgeSchedule(bool alwaysJudgeSchedule) async {
    await _localStorage.then((value) => value.setBool(storeScoreboardAlwaysJudgeSchedule, alwaysJudgeSchedule));
  }

  static Future<bool> getAlwaysJudgeSchedule() async {
    try {
      var alwaysJudgeSchedule = await _localStorage.then((value) => value.getBool(storeScoreboardAlwaysJudgeSchedule));
      if (alwaysJudgeSchedule != null) {
        return alwaysJudgeSchedule;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}

class Scoreboard extends StatefulWidget {
  const Scoreboard({Key? key}) : super(key: key);

  @override
  State<Scoreboard> createState() => _ScoreboardState();
}

class _ScoreboardState extends State<Scoreboard> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  Event? _eventData;
  List<Team>? _teamData;
  List<GameMatch>? _matchData;
  List<JudgingSession>? _judgingData;

  bool _alwaysMatchInfo = false;
  bool _alwaysJudgeInfo = false;

  void setEvent(Event event) {
    if (mounted) {
      setState(() {
        _eventData = event;
      });
    }
  }

  void setTeams(List<Team> teams) async {
    if (mounted) {
      if (!listEquals(_teamData, teams)) {
        setState(() {
          _teamData = teams;
        });
      }
    }
  }

  void setMatches(List<GameMatch> matches) async {
    if (mounted) {
      // check for equality
      if (!listEquals(_matchData, matches)) {
        setState(() {
          _matchData = matches;
        });
      }
    }
  }

  void setJudgingSessions(List<JudgingSession> sessions) async {
    if (mounted) {
      // check for equality
      if (!listEquals(_judgingData, sessions)) {
        setState(() {
          _judgingData = sessions;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    onEventUpdate((event) async => setEvent(event));
    onTeamsUpdate((teams) async => setTeams(teams));
    onMatchesUpdate((matches) async => setMatches(matches));
    onJudgingSessionsUpdate((sessions) async => setJudgingSessions(sessions));

    onJudgingSessionUpdate((j) async {
      // find judging session and update it
      int idx = _judgingData?.indexWhere((session) => session.sessionNumber == j.sessionNumber) ?? -1;
      if (idx != -1) {
        if (mounted) {
          setState(() {
            _judgingData?[idx] = j;
          });
        }
      }
    });

    onMatchUpdate((m) async {
      // find match and update it
      int idx = _matchData?.indexWhere((match) => match.matchNumber == m.matchNumber) ?? -1;
      if (idx != -1) {
        if (mounted) {
          setState(() {
            _matchData?[idx] = m;
          });
        }
      }
    });

    onTeamUpdate((t) async {
      // find team and update it
      int idx = _teamData?.indexWhere((team) => team.teamNumber == t.teamNumber) ?? -1;
      if (idx != -1) {
        if (mounted) {
          setState(() {
            _teamData?[idx] = t;
          });
        }
      }
    });

    ScoreboardUtil.getAlwaysMatchSchedule().then((value) async {
      setState(() {
        _alwaysMatchInfo = value;
      });
    });

    ScoreboardUtil.getAlwaysJudgeSchedule().then((value) async {
      setState(() {
        _alwaysJudgeInfo = value;
      });
    });

    // delay and get event data
    Future.delayed(const Duration(seconds: 1), () async {
      if (!await Network.isConnected()) {
        getEvent().then((event) => setEvent(event));
        getTeams().then((teams) => setTeams(teams));
        getMatches().then((matches) => setMatches(matches));
      }
    });
  }

  Widget getTable() {
    double edgeInset = Responsive.isDesktop(context)
        ? 50
        : Responsive.isTablet(context)
            ? 20
            : 0;
    // if table has data display otherwise
    if (_teamData?.isNotEmpty ?? false) {
      return Expanded(
        child: Container(
          padding: EdgeInsets.fromLTRB(edgeInset, 0, edgeInset, 0),
          child: TeamTable(
            teams: _teamData ?? [],
            matches: _matchData ?? [],
            rounds: _eventData?.eventRounds ?? 3,
          ),
        ),
      );
    } else {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  Widget getJudgeInfo() {
    if (!Responsive.isMobile(context)) {
      double edgeInset = Responsive.isDesktop(context)
          ? 50
          : Responsive.isTablet(context)
              ? 20
              : 0;
      // if table has data display otherwise
      return Padding(
        padding: EdgeInsets.fromLTRB(edgeInset, 0, edgeInset, 0),
        child: JudgeInfo(
          alwaysJudgeSchedule: _alwaysJudgeInfo,
          judgingSessions: _judgingData ?? [],
          teams: _teamData ?? [],
          event: _eventData,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget getMatchInfo() {
    // only display if not mobile
    if (!Responsive.isMobile(context)) {
      double edgeInset = Responsive.isDesktop(context)
          ? 50
          : Responsive.isTablet(context)
              ? 20
              : 0;
      // if table has data display otherwise
      return Padding(
        padding: EdgeInsets.fromLTRB(edgeInset, 0, edgeInset, 0),
        child: MatchInfo(
          alwaysMatchInfo: _alwaysMatchInfo,
          teams: _teamData ?? [],
          matches: _matchData ?? [],
          event: _eventData,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TmsToolBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blueGrey[800],
            ),
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    const Text("Always Match Info: ", style: TextStyle(color: Colors.white)),
                    Theme(
                      data: ThemeData(unselectedWidgetColor: Colors.white),
                      child: Checkbox(
                        value: _alwaysMatchInfo,
                        onChanged: (v) {
                          setState(() {
                            ScoreboardUtil.setAlwaysMatchSchedule(v!);
                            _alwaysMatchInfo = v;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("Always Judge Info: ", style: TextStyle(color: Colors.white)),
                    Theme(
                      data: ThemeData(unselectedWidgetColor: Colors.white),
                      child: Checkbox(
                        value: _alwaysJudgeInfo,
                        onChanged: (v) {
                          setState(() {
                            ScoreboardUtil.setAlwaysJudgeSchedule(v!);
                            _alwaysJudgeInfo = v;
                          });
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          // main infinite table
          getJudgeInfo(),
          getTable(),
          getMatchInfo(),
        ],
      ),
    );
  }
}
