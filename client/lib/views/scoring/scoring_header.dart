import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/requests/publish_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/scoring/table_setup.dart';
import 'package:tms/utils/sorter_util.dart';

class ScoringHeader extends StatefulWidget {
  final double height;
  final Function(Team team, GameMatch match) onNextTeamMatch;
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
  int _rounds = 0;

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
              _nextTeam = _teams.firstWhere((team) => team.teamNumber == onTable.teamNumber);
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
    onEventUpdate((event) {
      setState(() {
        _rounds = event.eventRounds;
      });
    });
    onMatchesUpdate((matches) => setMatches(matches));
    onTeamsUpdate((teams) => setTeams(teams));

    // singular match update
    onMatchUpdate((match) {
      // find the first match that matches the match number and update it
      final idx = _matches.indexWhere((m) => m.matchNumber == match.matchNumber);
      if (idx != -1) {
        setState(() {
          _matches[idx] = match;
          setNextTableMatch();
        });
      }
    });

    // singular team update
    onTeamUpdate((team) {
      final idx = _teams.indexWhere((t) => t.teamNumber == team.teamNumber);
      if (idx != -1) {
        setState(() {
          _teams[idx] = team;
          setNextTableMatch();
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
    if (_locked) {
      return Text(
        "${_nextTeam?.teamNumber} | ${_nextTeam?.teamName}",
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    } else {
      return DropdownButton<String>(
        value: _nextTeam?.teamNumber.toString(),
        dropdownColor: Colors.blueGrey[800],
        onChanged: (String? newValue) {
          if (newValue != null) {
            final team = _teams.firstWhere((team) => team.teamNumber.toString() == newValue);
            setState(() {
              _nextTeam = team;
              widget.onNextTeamMatch(_nextTeam!, _nextMatch!);
            });
          }
        },
        items: _teams.map<DropdownMenuItem<String>>((Team team) {
          return DropdownMenuItem<String>(
            value: team.teamNumber.toString(),
            child: Text(
              "${team.teamNumber} | ${team.teamName}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        }).toList(),
      );
    }
  }

  Widget getRoundWidget() {
    if (_locked) {
      return Text(
        "Round: ${_nextMatch?.roundNumber}",
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    } else {
      return DropdownButton<String>(
        value: _nextMatch?.roundNumber.toString(),
        dropdownColor: Colors.blueGrey[800],
        onChanged: (String? newValue) {
          if (newValue != null) {
            GameMatch match = LocalDatabaseMixin.matchDefault(); // create blank match for unlocked mode
            match.roundNumber = int.parse(newValue);
            setState(() {
              _nextMatch = match;
              widget.onNextTeamMatch(_nextTeam!, _nextMatch!);
            });
          }
        },
        items: List.generate(_rounds, (index) => index + 1).map<DropdownMenuItem<String>>((int round) {
          return DropdownMenuItem<String>(
            value: round.toString(),
            child: Text(
              "Round: $round",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        }).toList(),
      );
    }
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
        // color: AppTheme.isDarkTheme ? Colors.blueGrey[800] : Colors.white,
        // color: AppTheme.isDarkTheme ? Colors.transparent : Colors.white,
        // border: Border(
        //   bottom: BorderSide(color: AppTheme.isDarkTheme ? Colors.white : Colors.black),
        // ),
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
