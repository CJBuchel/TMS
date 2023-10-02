import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/scoring/table_setup.dart';
import 'package:tms/views/shared/tool_bar.dart';

class RefereeSchedule extends StatefulWidget {
  const RefereeSchedule({Key? key}) : super(key: key);
  @override
  State<RefereeSchedule> createState() => _RefereeScheduleState();
}

class _RefereeScheduleState extends State<RefereeSchedule> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  List<GameMatch> _loadedMatches = [];
  List<GameMatch> _tableMatches = [];
  List<Team> _teams = [];
  String _thisTable = "";

  void setMatches(List<GameMatch> matches) {
    RefereeTableUtil.getTable().then((thisTable) {
      List<GameMatch> tableMatches = [];
      for (var match in matches) {
        if (match.onTableFirst.table == thisTable || match.onTableSecond.table == thisTable) {
          tableMatches.add(match);
        }
      }

      if (mounted) {
        setState(() {
          _tableMatches = tableMatches;
        });
      }
    });
  }

  void setTeams(List<Team> teams) {
    if (mounted) {
      setState(() {
        _teams = teams;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    onMatchesUpdate((matches) => setMatches(matches));
    onTeamsUpdate((teams) => setTeams(teams));

    RefereeTableUtil.getTable().then((thisTable) {
      if (mounted) {
        setState(() {
          _thisTable = thisTable;
        });
      }
    });

    onMatchUpdate((m) {
      var index = _tableMatches.indexWhere((match) => match.matchNumber == m.matchNumber);
      if (index != -1) {
        if (mounted) {
          setState(() {
            _tableMatches[index] = m;
          });
        }
      }
    });

    onTeamUpdate((t) {
      var index = _teams.indexWhere((team) => team.teamNumber == t.teamNumber);
      if (index != -1) {
        if (mounted) {
          setState(() {
            _teams[index] = t;
          });
        }
      }
    });

    autoSubscribe("match", (m) {
      if (m.subTopic == "load") {
        if (m.message.isNotEmpty) {
          final jsonString = jsonDecode(m.message);
          SocketMatchLoadedMessage message = SocketMatchLoadedMessage.fromJson(jsonString);

          List<GameMatch> loadedMatches = [];
          for (var loadedMatchNumber in message.matchNumbers) {
            for (var match in _tableMatches) {
              if (match.matchNumber == loadedMatchNumber) {
                loadedMatches.add(match);
              }
            }
          }

          // check if the loaded matches are the same
          if (!listEquals(_loadedMatches, loadedMatches)) {
            if (mounted) {
              setState(() {
                _loadedMatches = loadedMatches;
              });
            }
          }
        }
      } else if (m.subTopic == "unload") {
        if (mounted) {
          setState(() {
            _loadedMatches = [];
          });
        }
      }
    });

    Future.delayed(const Duration(seconds: 1), () async {
      if (!await Network.isConnected()) {
        getTeams().then((teams) => setTeams(teams));
        getMatches().then((matches) => setMatches(matches));
      }
    });
  }

  Widget _styledHeader(String content) {
    return Center(child: Text(content, style: const TextStyle(fontWeight: FontWeight.bold)));
  }

  DataCell _styledCell(String context, {Color? color, bool? deferred}) {
    Widget child = Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            context,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (deferred ?? false)
          Align(
            alignment: Alignment.center,
            child: Divider(
              color: AppTheme.isDarkTheme ? Colors.white : Colors.black,
              thickness: 2,
            ),
          ),
      ],
    );

    return DataCell(
      Container(
        color: color ?? Colors.transparent,
        child: Center(child: child),
      ),
      showEditIcon: false,
      placeholder: false,
    );
  }

  DataRow2 _styledRow(GameMatch match, int index) {
    // check if this match is loaded
    bool isLoaded = _loadedMatches.map((e) => e.matchNumber).contains(match.matchNumber) ? true : false;

    // check if this match is deferred
    bool isDeferred = match.gameMatchDeferred;
    OnTable onTable = match.onTableFirst.table == _thisTable ? match.onTableFirst : match.onTableSecond;
    Team team = _teams.firstWhere((team) => team.teamNumber == onTable.teamNumber);

    return DataRow2(
      color: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (isLoaded) return Colors.orange;
        if (index.isEven) return match.complete ? Colors.green : Theme.of(context).splashColor; // Color for even rows
        return match.complete ? Colors.green : Theme.of(context).colorScheme.secondary.withOpacity(0.1);
      }),
      cells: [
        _styledCell(match.matchNumber, deferred: isDeferred),
        _styledCell(match.startTime, deferred: isDeferred),
        _styledCell(
          team.teamNumber,
          color: match.complete && !onTable.scoreSubmitted
              ? Colors.red
              : match.complete && onTable.scoreSubmitted
                  ? Colors.green
                  : null,
          deferred: isDeferred,
        ),
        _styledCell(
          team.teamName,
          color: match.complete && !onTable.scoreSubmitted
              ? Colors.red
              : match.complete && onTable.scoreSubmitted
                  ? Colors.green
                  : null,
          deferred: isDeferred,
        ),
      ],
    );
  }

  Widget getTable() {
    if (_tableMatches.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return DataTable2(
        headingRowColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          return Colors.transparent; // Color for header row
        }),
        columnSpacing: 10,
        columns: [
          DataColumn2(label: _styledHeader('Match'), size: ColumnSize.S),
          DataColumn2(label: _styledHeader('Time')),
          DataColumn2(label: _styledHeader('Team Number')),
          DataColumn2(label: _styledHeader('Team Name')),
        ],
        rows: _tableMatches.map((match) {
          int idx = _tableMatches.indexOf(match);
          return (_styledRow(match, idx));
        }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TmsToolBar(),
      body: getTable(),
    );
  }
}
