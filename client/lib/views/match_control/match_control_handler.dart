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
import 'package:tms/views/match_control/controls/controls_desktop.dart';
import 'package:tms/views/match_control/controls/controls_mobile.dart';
import 'package:tms/views/match_control/controls/controls_shared.dart';
import 'package:tms/views/match_control/tables/match_table.dart';
import 'package:tms/utils/sorter_util.dart';

class MatchControlHandler extends StatefulWidget {
  const MatchControlHandler({Key? key}) : super(key: key);

  @override
  State<MatchControlHandler> createState() => _MatchControlHandlerState();
}

class _MatchControlHandlerState extends State<MatchControlHandler> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  Event? _event;
  List<GameMatch> _matches = [];
  List<GameMatch> _loadedMatches = [];
  List<GameMatch> _selectedMatches = [];
  List<Team> _teams = [];

  // set event
  void setEvent(Event event) async {
    if (mounted) {
      setState(() {
        _event = event;
      });
    }
  }

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
    onEventUpdate((event) => setEvent(event));

    // add notifier for disconnect (remove loaded matches if we're disconnected)
    NetworkHttp.httpState.addListener(unloadOnDisconnect);
    NetworkWebSocket.wsState.addListener(unloadOnDisconnect);

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

    // delayed callback
    Future.delayed(const Duration(milliseconds: 500), () {
      getTeams().then((teams) => setTeams(teams));
      getMatches().then((matches) => setMatches(matches));
      getEvent().then((event) => setEvent(event));
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
                  child: MatchTable(
                    con: constraints,
                    event: _event,
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
              child: MatchTable(
                con: constraints,
                event: _event,
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
            isLoadable = checkCompletedMatchesHaveScores(_selectedMatches, _matches) ? isLoadable : false;
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
      ),
    );
  }
}
