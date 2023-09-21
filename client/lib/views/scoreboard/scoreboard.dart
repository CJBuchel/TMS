import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/schema/tms_schema.dart';
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

  bool _alwaysMatchSchedule = false;
  bool _alwaysJudgeSchedule = false;

  void setEvent(Event event) {
    if (mounted) {
      setState(() {
        _eventData = event;
      });
    }
  }

  void setTeams(List<Team> teams) {
    if (mounted) {
      setState(() {
        _teamData = teams;
      });
    }
  }

  void setMatches(List<GameMatch> matches) {
    if (mounted) {
      setState(() {
        _matchData = matches;
      });
    }
  }

  @override
  void initState() {
    onEventUpdate((event) => setEvent(event));
    onTeamsUpdate((teams) => setTeams(teams));
    onMatchesUpdate((matches) => setMatches(matches));

    onMatchUpdate((m) {
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

    onTeamUpdate((t) {
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

    ScoreboardUtil.getAlwaysMatchSchedule().then((value) {
      setState(() {
        _alwaysMatchSchedule = value;
      });
    });

    ScoreboardUtil.getAlwaysJudgeSchedule().then((value) {
      setState(() {
        _alwaysJudgeSchedule = value;
      });
    });
    super.initState();
  }

  Widget getTable() {
    // if table has data display otherwise
    if (_teamData?.isNotEmpty ?? false) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
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
          child: Text("No Event Data"),
        ),
      );
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
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
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
                        value: _alwaysMatchSchedule,
                        onChanged: (v) {
                          setState(() {
                            ScoreboardUtil.setAlwaysMatchSchedule(v!);
                            _alwaysMatchSchedule = v;
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
                        value: _alwaysJudgeSchedule,
                        onChanged: (v) {
                          setState(() {
                            ScoreboardUtil.setAlwaysJudgeSchedule(v!);
                            _alwaysJudgeSchedule = v;
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
          getTable(),
        ],
      ),
    );
  }
}
