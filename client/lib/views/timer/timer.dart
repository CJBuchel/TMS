import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/tool_bar.dart';
import 'package:tms/views/timer/clock.dart';
import 'package:tms/views/timer/header.dart';
import 'package:tms/views/timer/match_info.dart';

class Timer extends StatefulWidget {
  const Timer({super.key});

  @override
  State<Timer> createState() => _TimerState();
}

class _TimerState extends State<Timer> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  Event? _event;
  List<Team> _teams = [];
  List<GameMatch> _matches = [];
  List<GameMatch> _loadedMatches = [];
  List<OnTable> _loadedFirstTables = []; // first set of tables
  List<OnTable> _loadedSecondTables = []; // second set of tables
  List<String> _tableListeners = [];
  bool _timerEnabled = false;

  void setLoadedInfo(List<GameMatch> matches) async {
    // set first set of tables
    List<OnTable> loadedFirst = [];
    List<OnTable> loadedSecond = [];
    List<GameMatch> loadedMatches = [];
    bool enabled = false;

    // check if tables are in the table listener list, if so add them
    for (var match in matches) {
      // split evenly
      bool first = true;
      for (var onTable in match.matchTables) {
        if (_tableListeners.contains(onTable.table)) {
          if (first) {
            loadedFirst.add(onTable);
            first = false;
          } else {
            loadedSecond.add(onTable);
            first = true;
          }
          enabled = true;
        }
      }
      loadedMatches.add(match);
    }

    setState(() {
      _loadedFirstTables = loadedFirst;
      _loadedSecondTables = loadedSecond;
      _loadedMatches = loadedMatches;
      _timerEnabled = enabled;
    });
  }

  void setEvent(Event event) {
    if (mounted) {
      setState(() {
        _event = event;
      });
    }
  }

  void setTeams(List<Team> teams) {
    if (mounted) {
      setState(() {
        _teams = teams;
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

  void onThemeChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    onEventUpdate((event) => setEvent(event));
    onTeamsUpdate((teams) => setTeams(teams));
    onMatchesUpdate((matches) => setMatches(matches));

    onMatchUpdate((m) async {
      int idx = _matches.indexWhere((match) => match.matchNumber == m.matchNumber);
      if (idx != -1) {
        if (mounted) {
          _matches[idx] = m;
        }
      }
    });

    onTeamUpdate((t) async {
      int idx = _teams.indexWhere((team) => team.teamNumber == t.teamNumber);
      if (idx != -1) {
        if (mounted) {
          _teams[idx] = t;
        }
      }
    });

    autoSubscribe("match", (m) async {
      if (m.subTopic == "load") {
        if (m.message.isNotEmpty) {
          // on load
          final jsonString = jsonDecode(m.message);
          SocketMatchLoadedMessage message = SocketMatchLoadedMessage.fromJson(jsonString);

          List<GameMatch> loadedMatches = [];
          for (var loadedMatchNumber in message.matchNumbers) {
            for (var match in _matches) {
              if (match.matchNumber == loadedMatchNumber) {
                loadedMatches.add(match);
              }
            }
          }

          setLoadedInfo(loadedMatches);
        }
      } else if (m.subTopic == "unload") {
        // on unload
        setState(() {
          _loadedFirstTables = [];
          _loadedSecondTables = [];
          _loadedMatches = [];
        });
      }
    });

    AppTheme.isDarkThemeNotifier.addListener(onThemeChange);
  }

  @override
  void dispose() {
    AppTheme.isDarkThemeNotifier.removeListener(onThemeChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TmsToolBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // header
          Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: AppTheme.isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
            ),
            child: TimerHeader(
              matches: _matches,
              loadedMatches: _loadedMatches,
              event: _event,
              onTableListenerChanged: (listeners) {
                setState(() {
                  _tableListeners = listeners;
                });
              },
            ),
          ),

          // Clock
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Clock(enabled: _timerEnabled),
              ],
            ),
          ),

          // match info
          if (Responsive.isDesktop(context))
            SizedBox(
              height: 170, // allows for 3 tables (row height is 48, header is 26)
              child: TimerMatchInfo(
                teams: _teams,
                matches: _matches,
                loadedFirstTables: _loadedFirstTables,
                loadedSecondTables: _loadedSecondTables,
              ),
            ),
        ],
      ),
    );
  }
}
