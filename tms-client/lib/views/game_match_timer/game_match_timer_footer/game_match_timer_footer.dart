import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/views/game_match_timer/game_match_timer_footer/team_on_table_info.dart';
import 'package:tms/views/game_match_timer/game_match_timer_footer/teams_on_table_list.dart';
import 'package:tms/views/game_match_timer/timer_match_data.dart';

class GameMatchTimerFooter extends StatelessWidget {
  final TimerMatchData data;
  const GameMatchTimerFooter({
    Key? key,
    required this.data,
  }) : super(key: key);

  Widget _buildTeamsOnTablesList(BuildContext context, {required List<TeamOnTableInfo> teamsInfo}) {
    List<TeamOnTableInfo> leftTeamsInfo = [];
    List<TeamOnTableInfo> rightTeamsInfo = [];

    for (int i = 0; i < teamsInfo.length; i++) {
      if (i.isOdd) {
        rightTeamsInfo.add(teamsInfo[i]);
      } else {
        leftTeamsInfo.add(teamsInfo[i]);
      }
    }

    return Center(
      child: IntrinsicWidth(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TeamsOnTableList(teamsInfo: leftTeamsInfo, isLeft: true),
              TeamsOnTableList(teamsInfo: rightTeamsInfo, isLeft: false),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector2<TeamsProvider, TmsLocalStorageProvider, List<TeamOnTableInfo>>(
      selector: (context, teamsProvider, localStorageProvider) {
        List<TeamOnTableInfo> info = data.loadedMatches.expand((m) {
          return m.gameMatchTables.map((t) {
            return TeamOnTableInfo(
              matchNumber: m.matchNumber,
              teamNumber: teamsProvider.getTeam(t.teamNumber).teamNumber,
              teamName: teamsProvider.getTeam(t.teamNumber).name,
              onTable: t.table,
            );
          });
        }).toList();

        // filter out the tables that are not assigned
        if (localStorageProvider.timerAssignedTables.isNotEmpty) {
          return info.where((i) {
            return localStorageProvider.timerAssignedTables.contains(i.onTable);
          }).toList();
        } else {
          return info;
        }
      },
      builder: (context, teamsInfo, _) => _buildTeamsOnTablesList(context, teamsInfo: teamsInfo),
    );
  }
}
