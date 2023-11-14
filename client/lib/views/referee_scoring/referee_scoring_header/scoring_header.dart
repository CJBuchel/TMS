import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/requests/publish_requests.dart';
import 'package:tms/schema/tms_schema.dart';
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
  Team? _nextTeam;
  GameMatch? _nextMatch;
  GameMatch? _tableLoadedMatch;
  bool _locked = true; // locked to match controller

  List<GameMatch> _matches = [];
  List<Team> _teams = [];

  void sendTableLoadedMatch(String thisTable, {bool forceNone = false}) {
    if (_tableLoadedMatch != null) {
      publishRequest(SocketMessage(
        topic: "table",
        subTopic: thisTable,
        message: forceNone ? "" : _tableLoadedMatch?.matchNumber ?? "",
      )).then((res) {
        if (res != HttpStatus.ok) {
          Logger().e("Failed to send table loaded match, status code: $res");
        }
      });
    }
  }

  bool checkSetNextMatch(String thisTable, GameMatch match) {
    if (_locked) {
      if (_matches.isNotEmpty && _teams.isNotEmpty) {
        for (var onTable in match.matchTables) {
          if (onTable.table == thisTable && !onTable.scoreSubmitted) {
            setState(() {
              _nextMatch = match;
              _nextTeam = null;
              for (Team t in _teams) {
                if (t.teamNumber == onTable.teamNumber) {
                  _nextTeam = t;
                  break;
                }
              }
              if (_nextMatch != null && _nextTeam != null) {
                widget.onNextTeamMatch(_nextTeam!, _nextMatch!);
              }
              sendTableLoadedMatch(thisTable);
            });
            return true;
          }
        }
      }
    }
    return false;
  }

  void setNextTableMatch() {
    if (_tableLoadedMatch != null) {
      // override and set next match to the table loaded match
      RefereeTableUtil.getTable().then((thisTable) {
        checkSetNextMatch(thisTable, _tableLoadedMatch!);
      });
    } else {
      if (_matches.isNotEmpty && _teams.isNotEmpty) {
        RefereeTableUtil.getTable().then((thisTable) {
          // first check matches that have been completed
          for (var match in _matches) {
            if (match.complete && !match.gameMatchDeferred) {
              if (checkSetNextMatch(thisTable, match)) return;
            }
          }

          // then check matches that are not complete (i.e, default)
          for (var match in _matches) {
            if (!match.complete && !match.gameMatchDeferred) {
              if (checkSetNextMatch(thisTable, match)) return;
            }
          }

          // fall through (if no next matches are found, nor any are loaded)
          setState(() {
            _nextMatch = null;
            _nextTeam = null;
            widget.onNextTeamMatch(null, null);
            sendTableLoadedMatch(thisTable, forceNone: true);
          });
        });
      }
    }
  }

  void setTeams(List<Team> teams) {
    teams.sort((a, b) => a.teamNumber.compareTo(b.teamNumber));
    if (mounted) {
      setState(() {
        _teams = teams;
        setNextTableMatch();
      });
    }
  }

  void setMatches(List<GameMatch> matches) {
    matches = sortMatchesByTime(matches);
    if (mounted) {
      setState(() {
        _matches = matches;
        setNextTableMatch();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    onMatchesUpdate((matches) => setMatches(matches));
    onTeamsUpdate((teams) => setTeams(teams));

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

          // check if any of the loaded matches match this table
          RefereeTableUtil.getTable().then((thisTable) {
            for (var match in loadedMatches) {
              for (var onTable in match.matchTables) {
                if (onTable.table == thisTable) {
                  setState(() {
                    _tableLoadedMatch = match;
                    setNextTableMatch();
                  });
                  break;
                }
              }
            }
          });
        }
      } else if (m.subTopic == "unload") {
        setState(() {
          _tableLoadedMatch = null;
          setNextTableMatch();
        });
      }
    });

    // delayed
    Future.delayed(const Duration(milliseconds: 500), () {
      getMatches().then((matches) => setMatches(matches));
      getTeams().then((teams) => setTeams(teams));
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
      nextMatch: _nextMatch,
      nextTeam: _nextTeam,
      teams: _teams,
      locked: _locked,
      onTeamChange: (t, m) {
        widget.onNextTeamMatch(t, m);
      },
    );
  }

  Widget getRoundWidget() {
    return RoundDropdownWidget(
      nextMatch: _nextMatch,
      nextTeam: _nextTeam,
      locked: _locked,
      onRoundChange: (t, m) {
        widget.onNextTeamMatch(t, m);
      },
    );
  }

  Widget getMatchWidget() {
    return Text(
      _locked ? "Match: ${_nextMatch?.matchNumber}/${_matches.length}" : "None",
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
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
          PopupMenuButton(
            icon: const Icon(
              Icons.more_horiz,
              color: Colors.white,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                  child: ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: const Text("Switch Table"),
                onTap: () {
                  Logger().i("Switch Table");
                  RefereeTableUtil.setTable("").then((v) {
                    Navigator.pop(context);
                    Navigator.popAndPushNamed(context, "/referee/table_setup");
                  });
                },
              )),
              PopupMenuItem(
                child: ListTile(
                  leading: _locked ? const Icon(Icons.lock_open) : const Icon(Icons.lock),
                  title: _locked ? const Text("Unlock") : const Text("Lock"),
                  onTap: () {
                    RefereeTableUtil.getTable().then((thisTable) {
                      sendTableLoadedMatch(thisTable, forceNone: true);
                      setState(() {
                        _locked = !_locked;
                        widget.onLock(_locked);
                        Navigator.pop(context);
                      });
                    });
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text("Schedule"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/referee/schedule");
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.book),
                  title: const Text("Rule Book"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/referee/rule_book");
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
