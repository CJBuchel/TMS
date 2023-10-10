import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/requests/match_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/matches/add_match/add_match.dart';
import 'package:tms/views/admin/dashboard/matches/match_edit_row.dart';
import 'package:tms/views/shared/network_error_popup.dart';
import 'package:tms/views/shared/sorter_util.dart';

class MatchEditTable extends StatefulWidget {
  const MatchEditTable({Key? key}) : super(key: key);

  @override
  State<MatchEditTable> createState() => _MatchTableState();
}

class _MatchTableState extends State<MatchEditTable> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  List<GameMatch> _matches = [];
  List<Team> _teams = [];

  set setMatches(List<GameMatch> value) {
    if (mounted) {
      value = sortMatchesByTime(value);
      setState(() {
        _matches = value;
      });
    }
  }

  set setMatch(GameMatch match) {
    if (mounted) {
      // find match if exists
      final index = _matches.indexWhere((m) => m.matchNumber == match.matchNumber);
      if (index != -1) {
        setState(() {
          _matches[index] = match;
        });
      } else {
        setState(() {
          _matches.add(match);
        });
      }
    }
  }

  set setTeams(List<Team> teams) {
    if (mounted) {
      setState(() {
        _teams = teams;
      });
    }
  }

  set setTeam(Team team) {
    if (mounted) {
      // find team if exists
      final index = _teams.indexWhere((t) => t.teamNumber == team.teamNumber);
      if (index != -1) {
        setState(() {
          _teams[index] = team;
        });
      } else {
        setState(() {
          _teams.add(team);
        });
      }
    }
  }

  void fetchMatches() {
    getMatchesRequest().then((value) {
      if (value.item1 == HttpStatus.ok) {
        setMatches = value.item2;
      } else {
        showNetworkError(value.item1, context, subMessage: "Error fetching matches");
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // live setters
    onMatchesUpdate((m) => setMatches = m);
    onMatchUpdate((m) => setMatch = m);
    onTeamsUpdate((t) => setTeams = t);
    onTeamUpdate((t) => setTeam = t);
  }

  Widget _topButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            fetchMatches();
          },
          icon: const Icon(Icons.refresh, color: Colors.orange),
        ),

        // add match
        AddMatch(matches: _matches),
      ],
    );
  }

  Widget _getTable() {
    // list view table
    return ListView.builder(
      itemCount: _matches.length,
      itemBuilder: (context, index) {
        bool isDeferred = _matches[index].gameMatchDeferred;
        bool isComplete = _matches[index].complete;

        Color rowColor = Colors.transparent; // default

        if (isDeferred) {
          rowColor = Colors.cyan;
        } else if (index.isEven) {
          if (isComplete) {
            rowColor = Colors.green;
          } else {
            rowColor = Theme.of(context).splashColor;
          }
        } else {
          if (isComplete) {
            rowColor = Colors.green[300] ?? Colors.green;
          } else {
            rowColor = Theme.of(context).colorScheme.secondary.withOpacity(0.1);
          }
        }

        return MatchEditRow(match: _matches[index], teams: _teams, rowColor: rowColor);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: ((context, constraints) {
      return Column(
        children: [
          SizedBox(
            height: 50,
            child: _topButtons(),
          ),

          // main table
          Expanded(
            child: SizedBox(
              width: constraints.maxWidth * 0.9,
              child: _getTable(),
            ),
          ),
        ],
      );
    }));
  }
}
