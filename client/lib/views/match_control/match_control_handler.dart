import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/network/http.dart';
import 'package:tms/network/network.dart';
import 'package:tms/network/ws.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/value_listenable_utils.dart';
import 'package:tms/views/match_control/controls/controls_desktop.dart';
import 'package:tms/views/match_control/match_control_floating_buttons.dart';
import 'package:tms/views/match_control/tables/match_table.dart';
import 'package:tms/utils/sorter_util.dart';

class MatchControlHandler extends StatefulWidget {
  const MatchControlHandler({Key? key}) : super(key: key);

  @override
  State<MatchControlHandler> createState() => _MatchControlHandlerState();
}

class _MatchControlHandlerState extends State<MatchControlHandler> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  final ValueNotifier<Event?> _eventNotifier = ValueNotifier<Event?>(null);
  final ValueNotifier<List<Team>> _teamsNotifier = ValueNotifier<List<Team>>([]);
  // matches
  final ValueNotifier<List<GameMatch>> _matchesNotifier = ValueNotifier<List<GameMatch>>([]);
  final ValueNotifier<List<GameMatch>> _selectedMatchesNotifier = ValueNotifier<List<GameMatch>>([]);
  final ValueNotifier<List<GameMatch>> _loadedMatchesNotifier = ValueNotifier<List<GameMatch>>([]);

  // set event
  void setEvent(Event event) async {
    if (mounted) {
      if (_eventNotifier.value != event) {
        _eventNotifier.value = event;
      }
    }
  }

  // Set teams
  void setTeams(List<Team> teams) async {
    if (mounted) {
      if (!listEquals(_teamsNotifier.value, teams)) {
        _teamsNotifier.value = teams;
      }
    }
  }

  void setMatches(List<GameMatch> gameMatches) async {
    if (mounted) {
      if (!listEquals(_matchesNotifier.value, gameMatches)) {
        _matchesNotifier.value = sortMatchesByTime(gameMatches);
      }
    }
  }

  void onSelectedMatches(List<GameMatch> matches) {
    if (mounted) {
      if (!listEquals(_selectedMatchesNotifier.value, matches)) {
        if (_loadedMatchesNotifier.value.isEmpty) {
          _selectedMatchesNotifier.value = matches;
        }
      }
    }
  }

  void unloadOnDisconnect() async {
    if (mounted) {
      var states = await Network.getStates();
      if (states.item1 != NetworkHttpConnectionState.connected || states.item2 != NetworkWebSocketState.connected) {
        _loadedMatchesNotifier.value = [];
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
        _loadedMatchesNotifier.value = [];
        _selectedMatchesNotifier.value = [];
      }
    });

    autoSubscribe("match", (m) {
      if (m.subTopic == "load") {
        if (m.message.isNotEmpty) {
          final jsonString = jsonDecode(m.message);
          SocketMatchLoadedMessage message = SocketMatchLoadedMessage.fromJson(jsonString);

          List<GameMatch> loadedMatches = [];
          for (var loadedMatchNumber in message.matchNumbers) {
            for (var match in _matchesNotifier.value) {
              if (match.matchNumber == loadedMatchNumber) {
                loadedMatches.add(match);
              }
            }
          }

          // check if the loaded matches are the same
          if (!listEquals(_loadedMatchesNotifier.value, loadedMatches)) {
            _loadedMatchesNotifier.value = loadedMatches;
          }

          if (!listEquals(_selectedMatchesNotifier.value, loadedMatches)) {
            _selectedMatchesNotifier.value = loadedMatches;
          }
        }
      } else if (m.subTopic == "unload") {
        if (mounted) {
          _loadedMatchesNotifier.value = [];
        }
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
                    teamsNotifier: _teamsNotifier,
                    matchesNotifier: _matchesNotifier,
                    selectedMatchesNotifier: _selectedMatchesNotifier,
                    loadedMatchesNotifier: _loadedMatchesNotifier,
                  ),
                ),
                SizedBox(
                  width: (constraints.maxWidth / 2), // 50%
                  child: MatchTable(
                    con: constraints,
                    event: _eventNotifier,
                    matches: _matchesNotifier,
                    onSelected: onSelectedMatches,
                    selectedMatches: _selectedMatchesNotifier,
                    loadedMatches: _loadedMatchesNotifier,
                  ),
                ),
              ],
            );
          } else {
            return SizedBox(
              width: constraints.maxWidth,
              child: MatchTable(
                con: constraints,
                event: _eventNotifier,
                matches: _matchesNotifier,
                selectedMatches: _selectedMatchesNotifier,
                onSelected: onSelectedMatches,
                loadedMatches: _loadedMatchesNotifier,
              ),
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          if (Responsive.isMobile(context)) {
            return ValueListenableBuilder(
              valueListenable: _matchesNotifier,
              builder: (context, matches, child) {
                return ValueListenableBuilder3(
                  first: _teamsNotifier,
                  second: _selectedMatchesNotifier,
                  third: _loadedMatchesNotifier,
                  builder: (context, teams, selected, loaded, _) {
                    return MatchControlFloatingButtons(
                      teams: teams,
                      matches: matches,
                      selectedMatches: selected,
                      loadedMatches: loaded,
                    );
                  },
                );
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
