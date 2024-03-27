import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/requests/publish_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/value_listenable_utils.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/popup_menu_widget.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/round_widget.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/team_widget.dart';
import 'package:tms/views/referee_scoring/table_setup.dart';
import 'package:tms/utils/sorter_util.dart';

class ScoringHeader extends StatefulWidget {
  final double height;
  final Function(Team? team, GameMatch? match) onNextTeamMatch;
  final Function(bool locked) onLock;
  const ScoringHeader({
    Key? key,
    required this.height,
    required this.onNextTeamMatch,
    required this.onLock,
  }) : super(key: key);

  @override
  State<ScoringHeader> createState() => _ScoringHeaderState();
}

class _ScoringHeaderState extends State<ScoringHeader> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  // controllers from header
  final ValueNotifier<Team?> _nextTeamNotifier = ValueNotifier<Team?>(null);
  set _setNextTeamNotifier(Team? team) {
    if (_nextTeamNotifier.value != team) {
      _nextTeamNotifier.value = team;
    }
  }

  final ValueNotifier<GameMatch?> _nextMatchNotifier = ValueNotifier<GameMatch?>(null);
  set _setNextMatchNotifier(GameMatch? match) {
    if (_nextMatchNotifier.value != match) {
      _nextMatchNotifier.value = match;
    }
  }

  void setNextTeamMatch(Team? team, GameMatch? match) async {
    _setNextTeamNotifier = team;
    _setNextMatchNotifier = match;
    widget.onNextTeamMatch(team, match);
  }

  final ValueNotifier<GameMatch?> _tableLoadedMatchNotifier = ValueNotifier<GameMatch?>(null);
  final ValueNotifier<bool> _lockedNotifier = ValueNotifier<bool>(true);

  // matches and teams
  final ValueNotifier<List<GameMatch>> _matchesNotifier = ValueNotifier<List<GameMatch>>([]);
  final ValueNotifier<List<Team>> _teamsNotifier = ValueNotifier<List<Team>>([]);

  void sendTableLoadedMatch(String thisTable, {bool forceNone = false}) async {
    if (_tableLoadedMatchNotifier.value != null) {
      publishRequest(SocketMessage(
        topic: "table",
        subTopic: thisTable,
        message: forceNone ? "" : _tableLoadedMatchNotifier.value?.matchNumber ?? "",
      )).then((res) {
        if (res != HttpStatus.ok) {
          Logger().e("Failed to send table loaded match, status code: $res");
        }
      });
    }
  }

  Future<bool> checkSetNextMatch(String thisTable, GameMatch match) async {
    if (_lockedNotifier.value) {
      if (_matchesNotifier.value.isNotEmpty && _teamsNotifier.value.isNotEmpty) {
        for (var onTable in match.matchTables) {
          if (onTable.table == thisTable && !onTable.scoreSubmitted) {
            if (_nextMatchNotifier.value != match) {
              _setNextMatchNotifier = match;
            }

            _setNextTeamNotifier = null;

            for (Team t in _teamsNotifier.value) {
              if (t.teamNumber == onTable.teamNumber) {
                _setNextTeamNotifier = t;
                break;
              }
            }
            if (_nextMatchNotifier.value != null && _nextTeamNotifier.value != null) {
              widget.onNextTeamMatch(_nextTeamNotifier.value!, _nextMatchNotifier.value!);
            }
            sendTableLoadedMatch(thisTable);

            return true;
          }
        }
      }
    }
    return false;
  }

  void setNextTableMatch() {
    if (_tableLoadedMatchNotifier.value != null) {
      // override and set next match to the table loaded match
      RefereeTableUtil.getTable().then((thisTable) {
        checkSetNextMatch(thisTable, _tableLoadedMatchNotifier.value!);
      });
    } else {
      if (_matchesNotifier.value.isNotEmpty && _teamsNotifier.value.isNotEmpty) {
        RefereeTableUtil.getTable().then((thisTable) async {
          // first check matches that have been completed
          for (var match in _matchesNotifier.value) {
            if (match.complete && !match.gameMatchDeferred) {
              if (await checkSetNextMatch(thisTable, match)) return;
            }
          }

          // then check matches that are not complete (i.e, default)
          for (var match in _matchesNotifier.value) {
            if (!match.complete && !match.gameMatchDeferred) {
              if (await checkSetNextMatch(thisTable, match)) return;
            }
          }

          // fall through (if no next matches are found, nor any are loaded)
          setNextTeamMatch(null, null);
          sendTableLoadedMatch(thisTable, forceNone: true);
        });
      }
    }
  }

  void _setTeams(List<Team> teams) async {
    if (mounted) {
      if (!listEquals(_teamsNotifier.value, teams)) {
        _teamsNotifier.value = teams;
        setNextTableMatch();
      }
    }
  }

  void _setMatches(List<GameMatch> matches) async {
    matches = sortMatchesByTime(matches);
    if (mounted) {
      if (!listEquals(_matchesNotifier.value, matches)) {
        _matchesNotifier.value = matches;
        setNextTableMatch();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    onMatchesUpdate((matches) => _setMatches(matches));
    onTeamsUpdate((teams) => _setTeams(teams));

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

          // check if any of the loaded matches match this table
          RefereeTableUtil.getTable().then((thisTable) {
            for (var match in loadedMatches) {
              for (var onTable in match.matchTables) {
                if (onTable.table == thisTable) {
                  if (_tableLoadedMatchNotifier.value != match) {
                    _tableLoadedMatchNotifier.value = match;
                  }
                  setNextTableMatch();
                  break;
                }
              }
            }
          });
        }
      } else if (m.subTopic == "unload") {
        _tableLoadedMatchNotifier.value = null;
        setNextTableMatch();
      }
    });

    // delayed
    Future.delayed(const Duration(milliseconds: 500), () {
      getMatches().then((matches) => _setMatches(matches));
      getTeams().then((teams) => _setTeams(teams));
    });

    setNextTableMatch();
  }

  @override
  void dispose() {
    super.dispose();
    RefereeTableUtil.getTable().then((thisTable) {
      sendTableLoadedMatch(thisTable, forceNone: true);
    });
  }

  Widget getTeamWidget() {
    return TeamDropdownWidget(
      nextMatchNotifier: _nextMatchNotifier,
      nextTeamNotifier: _nextTeamNotifier,
      teamsNotifier: _teamsNotifier,
      lockedNotifier: _lockedNotifier,
      onTeamChange: (t, m) {
        setNextTeamMatch(t, m);
      },
    );
  }

  Widget getRoundWidget() {
    return RoundDropdownWidget(
      nextMatchNotifier: _nextMatchNotifier,
      nextTeamNotifier: _nextTeamNotifier,
      lockedNotifier: _lockedNotifier,
      onRoundChange: (t, m) {
        setNextTeamMatch(t, m);
      },
    );
  }

  Widget getMatchWidget() {
    return ValueListenableBuilder3(
      first: _nextMatchNotifier,
      second: _matchesNotifier,
      third: _lockedNotifier,
      builder: (context, nextMatch, matches, locked, _) {
        return Text(
          locked ? "Match: ${nextMatch?.matchNumber}/${matches.length}" : "None",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          getTeamWidget(),
          getRoundWidget(),
          getMatchWidget(),
          ScoringHeaderPopupMenu(
            lockedNotifier: _lockedNotifier,
            sendTableLoadedMatch: (thisTable, force) => sendTableLoadedMatch(thisTable, forceNone: force),
            changeLocked: (locked) {
              _lockedNotifier.value = locked;
              widget.onLock(locked);
            },
          ),
        ],
      ),
    );
  }
}
