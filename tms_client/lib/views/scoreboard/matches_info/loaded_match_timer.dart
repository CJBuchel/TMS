import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/models/team_on_table_info.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/widgets/team_widgets/team_on_table_row.dart';
import 'package:tms/widgets/animated/infinite_vertical_list.dart';
import 'package:tms/widgets/timers/match_timer.dart';

class _TeamsOnTableList extends StatelessWidget {
  final List<TeamOnTableInfo> teamsInfo;
  final Color? evenColor;
  final Color? oddColor;
  final bool isLeft;

  const _TeamsOnTableList({
    Key? key,
    required this.teamsInfo,
    required this.evenColor,
    required this.oddColor,
    required this.isLeft,
  }) : super(key: key);

  Color? _getBackgroundColor(BuildContext context, int index, {bool isLeft = true}) {
    Color? evenLightBackground = Theme.of(context).scaffoldBackgroundColor;
    Color? oddLightBackground = Theme.of(context).cardColor;

    Color? evenDarkBackground = Theme.of(context).scaffoldBackgroundColor;
    Color? oddDarkBackground = lighten(Theme.of(context).scaffoldBackgroundColor, 0.05);

    Color? evenBackground = Theme.of(context).brightness == Brightness.light ? evenLightBackground : evenDarkBackground;
    Color? oddBackground = Theme.of(context).brightness == Brightness.light ? oddLightBackground : oddDarkBackground;

    return index.isOdd ? oddBackground : evenBackground;
  }

  @override
  Widget build(BuildContext context) {
    double childHeight = 40;
    MainAxisAlignment mainAxisAlignment = isLeft ? MainAxisAlignment.end : MainAxisAlignment.start;

    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            height: childHeight,
            color: Theme.of(context).cardColor,
            child: Row(
              mainAxisAlignment: mainAxisAlignment,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    height: childHeight,
                    color: oddColor,
                    child: Center(
                      child: Text(
                        isLeft ? "On Table" : "Team",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: childHeight,
                    color: evenColor,
                    child: const Center(
                      child: Text(
                        "Name",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: childHeight,
                    color: oddColor,
                    child: Center(
                      child: Text(
                        isLeft ? "Team" : "On Table",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedInfiniteVerticalList(
              children: List<Widget>.generate(teamsInfo.length, (index) {
                return Container(
                  height: childHeight,
                  color: _getBackgroundColor(context, index, isLeft: isLeft),
                  child: TeamOnTableRow(
                    info: teamsInfo[index],
                    isLeft: isLeft,
                    textStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                    ),
                  ),
                );
              }),
              childHeight: childHeight,
            ),
          ),
        ],
      ),
    );
  }
}

class LoadedMatchTimer extends StatelessWidget {
  final List<GameMatch> loadedMatches;

  const LoadedMatchTimer({
    Key? key,
    required this.loadedMatches,
  }) : super(key: key);

  Widget _buildTeamsOnTablesList(BuildContext context, {required List<TeamOnTableInfo> teamsInfo}) {
    Color? evenDarkBackground = const Color(0xFF1B6A92);
    Color? oddDarkBackground = const Color(0xFF27A07A);

    Color? evenLightBackground = const Color(0xFF9CDEFF);
    Color? oddLightBackground = const Color(0xFF81FFD7);

    Color? evenBackground = Theme.of(context).brightness == Brightness.light ? evenLightBackground : evenDarkBackground;
    Color? oddBackground = Theme.of(context).brightness == Brightness.light ? oddLightBackground : oddDarkBackground;

    List<TeamOnTableInfo> leftTeamsInfo = [];
    List<TeamOnTableInfo> rightTeamsInfo = [];

    for (int i = 0; i < teamsInfo.length; i++) {
      if (i.isOdd) {
        rightTeamsInfo.add(teamsInfo[i]);
      } else {
        leftTeamsInfo.add(teamsInfo[i]);
      }
    }

    List<String> matchNumbers = teamsInfo.map((e) => e.matchNumber).toSet().toList();

    return Container(
      color: evenBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _TeamsOnTableList(
              teamsInfo: leftTeamsInfo,
              evenColor: evenBackground,
              oddColor: oddBackground,
              isLeft: true,
            ),
          ),
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            width: 300,
            child: Column(
              children: [
                Container(
                  height: 40,
                  color: evenBackground,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Match: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        // get all match numbers
                        matchNumbers.join(", "),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 120,
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: MatchTimer.full(
                    soundEnabled: true,
                    fontSize: 100,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _TeamsOnTableList(
              teamsInfo: rightTeamsInfo,
              evenColor: evenBackground,
              oddColor: oddBackground,
              isLeft: false,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<TeamsProvider, List<TeamOnTableInfo>>(
      selector: (_, provider) {
        return loadedMatches.expand((m) {
          return m.gameMatchTables.map((t) {
            return TeamOnTableInfo(
              matchNumber: m.matchNumber,
              teamNumber: provider.getTeam(t.teamNumber).teamNumber,
              teamName: provider.getTeam(t.teamNumber).name,
              onTable: t.table,
            );
          });
        }).toList();
      },
      builder: (context, teamsInfo, _) {
        return Container(
          height: 160, // 3*40, then + 40 for header
          child: _buildTeamsOnTablesList(context, teamsInfo: teamsInfo),
        );
      },
    );
  }
}
