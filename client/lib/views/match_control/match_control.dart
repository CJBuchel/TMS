import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/network/http.dart';
import 'package:tms/network/network.dart';
import 'package:tms/network/ws.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/match_control/controls_desktop.dart';
import 'package:tms/views/match_control/controls_mobile.dart';
import 'package:tms/views/match_control/controls_shared.dart';
import 'package:tms/views/match_control/table.dart';
import 'package:tms/views/shared/sorter_util.dart';
import 'package:tms/views/shared/tool_bar.dart';

class MatchControl extends StatefulWidget {
  const MatchControl({Key? key}) : super(key: key);

  @override
  State<MatchControl> createState() => _MatchControlState();
}

class _MatchControlState extends State<MatchControl> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  List<GameMatch> _matches = [];
  List<GameMatch> _loadedMatches = [];
  List<GameMatch> _selectedMatches = [];
  List<Team> _teams = [];

  // Set teams
  void setTeams(List<Team> teams) async {
    if (mounted) {
      List<Team> t = [];

      teams.sort((a, b) => int.parse(a.teamNumber).compareTo(int.parse(b.teamNumber)));

      for (var team in teams) {
        t.add(team);
      }

      setState(() {
        _teams = t;
      });
    }
  }

  void setMatches(List<GameMatch> gameMatches) async {
    if (mounted) {
      List<GameMatch> m = [];

      gameMatches = sortMatchesByTime(gameMatches);

      for (var match in gameMatches) {
        m.add(match);
      }

      setState(() {
        _matches = m;
      });
    }
  }

  void onSelectedMatches(List<GameMatch> matches) {
    if (mounted) {
      if (_loadedMatches.isEmpty) {
        setState(() {
          _selectedMatches.clear();
          _selectedMatches.addAll(matches);
        });
      }
    }
  }

  void unloadOnDisconnect() async {
    if (mounted) {
      var states = await Network.getStates();
      if (states.item1 != NetworkHttpConnectionState.connected || states.item2 != NetworkWebSocketState.connected) {
        setState(() {
          _loadedMatches = [];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    onTeamsUpdate((teams) => setTeams(teams));
    onMatchesUpdate((matches) => setMatches(matches));

    // add notifier for disconnect (remove loaded matches if we're disconnected)
    NetworkHttp.httpState.addListener(unloadOnDisconnect);
    NetworkWebSocket.wsState.addListener(unloadOnDisconnect);

    onTeamUpdate((team) {
      int idx = _teams.indexWhere((t) => t.teamNumber == team.teamNumber);
      if (idx != -1) {
        setState(() {
          _teams[idx] = team;
        });
      }
    });

    onMatchUpdate((match) {
      int idx = _matches.indexWhere((m) => m.matchNumber == match.matchNumber);
      if (idx != -1) {
        setState(() {
          _matches[idx] = match;
        });
      }
    });

    autoSubscribe("clock", (m) {
      if (m.subTopic == "end") {
        setState(() {
          _loadedMatches = [];
          _selectedMatches = [];
        });
      }
    });

    autoSubscribe("match", (m) {
      if (m.subTopic == "load") {
        if (m.message.isNotEmpty) {
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

          // check if the loaded matches are the same
          if (!listEquals(_loadedMatches, loadedMatches)) {
            setState(() {
              _loadedMatches = loadedMatches;
            });
          }

          if (!listEquals(_selectedMatches, loadedMatches)) {
            setState(() {
              _selectedMatches.clear();
              _selectedMatches.addAll(loadedMatches);
            });
          }
        }
      } else if (m.subTopic == "unload") {
        setState(() {
          _loadedMatches = [];
        });
      }
    });

    Future.delayed(const Duration(seconds: 1), () async {
      if (!await Network.isConnected()) {
        getTeams().then((teams) => setTeams(teams));
        getMatches().then((matches) => setMatches(matches));
      }
    });
  }

  @override
  void dispose() {
    NetworkHttp.httpState.removeListener(unloadOnDisconnect);
    NetworkWebSocket.wsState.removeListener(unloadOnDisconnect);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const TmsToolBar(),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (!Responsive.isMobile(context)) {
              return Row(
                children: [
                  SizedBox(
                    width: constraints.maxWidth / 2, // 50%
                    child: MatchControlDesktopControls(
                      con: constraints,
                      teams: _teams,
                      matches: _matches,
                      loadedMatches: _loadedMatches,
                      selectedMatches: _selectedMatches,
                    ),
                  ),
                  SizedBox(
                    width: (constraints.maxWidth / 2), // 50%
                    child: MatchControlTable(
                      con: constraints,
                      matches: _matches,
                      onSelected: onSelectedMatches,
                      selectedMatches: _selectedMatches,
                      loadedMatches: _loadedMatches,
                    ),
                  ),
                ],
              );
            } else {
              return SizedBox(
                width: constraints.maxWidth,
                child: MatchControlTable(
                  con: constraints,
                  matches: _matches,
                  selectedMatches: _selectedMatches,
                  onSelected: onSelectedMatches,
                  loadedMatches: _loadedMatches,
                ),
              );
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: LayoutBuilder(
          builder: (context, constraints) {
            if (Responsive.isMobile(context)) {
              bool isLoadable = _selectedMatches.isNotEmpty && _loadedMatches.isEmpty && _selectedMatches.every((element) => !element.complete);

              for (var selectedMatch in _selectedMatches) {
                // find any previous matches that are complete and tables that have not submitted their scores
                for (var previousMatch in _matches.where((element) => element.complete)) {
                  if (previousMatch.onTableFirst.table == selectedMatch.onTableFirst.table) {
                    if (!previousMatch.onTableFirst.scoreSubmitted) {
                      isLoadable = false;
                    }
                  }
                  if (previousMatch.onTableSecond.table == selectedMatch.onTableSecond.table) {
                    if (!previousMatch.onTableSecond.scoreSubmitted) {
                      isLoadable = false;
                    }
                  }
                }
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                      heroTag: "load-unload",
                      onPressed: () {
                        if (_loadedMatches.isNotEmpty) {
                          loadMatch(MatchLoadStatus.unload, context, _selectedMatches).then((value) {
                            if (value != HttpStatus.ok) {
                              displayErrorDialog(value, context);
                            }
                          });
                        } else if (isLoadable) {
                          loadMatch(MatchLoadStatus.load, context, _selectedMatches).then((value) {
                            if (value != HttpStatus.ok) {
                              displayErrorDialog(value, context);
                            }
                          });
                        }
                      },
                      enableFeedback: true,
                      backgroundColor: (isLoadable || _loadedMatches.isNotEmpty) ? Colors.orange : Colors.grey,
                      child: _loadedMatches.isEmpty
                          ? const Icon(Icons.arrow_downward, color: Colors.white)
                          : const Icon(Icons.arrow_upward, color: Colors.white)),
                  FloatingActionButton(
                    heroTag: "next",
                    onPressed: () {
                      if (_selectedMatches.isNotEmpty && _loadedMatches.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchControlMobileControls(
                              teams: _teams,
                              matches: _matches,
                              loadedMatches: _loadedMatches,
                              selectedMatches: _selectedMatches,
                            ),
                          ),
                        );
                      }
                    },
                    enableFeedback: true,
                    backgroundColor: (_selectedMatches.isNotEmpty && _loadedMatches.isNotEmpty) ? Colors.blue[300] : Colors.grey,
                    child: const Icon(Icons.double_arrow, color: Colors.white),
                  ),
                ],
              );
            } else {
              return const SizedBox();
            }
          },
        ));
  }
}
