import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/views/game_match_timer/timer_match_data.dart';
import 'package:tms/widgets/animated/infinite_vertical_list.dart';

class _MatchInfoTableData {
  final String matchNumber;
  final String teamNumber;
  final String teamName;
  final String onTable;

  _MatchInfoTableData({
    required this.matchNumber,
    required this.teamNumber,
    required this.teamName,
    required this.onTable,
  });
}

class GameMatchTimerFooter extends StatelessWidget {
  final ValueNotifier<TimerMatchData> data;
  const GameMatchTimerFooter({
    Key? key,
    required this.data,
  }) : super(key: key);

  Color? _getBackgroundColor(int index, {bool isLeft = true}) {
    if (isLeft) {
      return index.isEven ? Colors.deepPurple[900] : Colors.deepPurple[800];
    } else {
      return index.isEven ? Colors.pink[900] : Colors.pink[800];
    }
  }

  BorderSide _getBorderSide(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return const BorderSide(
        color: Colors.black,
        width: 1,
      );
    } else {
      return BorderSide.none;
    }
  }

  Widget _buildInfoRow(BuildContext context, _MatchInfoTableData info, {bool isLeft = true}) {
    MainAxisAlignment mainAxisAlignment = isLeft ? MainAxisAlignment.end : MainAxisAlignment.start;

    Widget tNumWidget = Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      decoration: ShapeDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.circular(10),
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isLeft ? 10 : 0),
            bottomLeft: Radius.circular(isLeft ? 10 : 0),
            topRight: Radius.circular(isLeft ? 0 : 10),
            bottomRight: Radius.circular(isLeft ? 0 : 10),
          ),
          side: _getBorderSide(context),
        ),
      ),
      child: Text(
        textAlign: TextAlign.center,
        info.teamNumber,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
    );

    Widget tNaWidget = Text(
      textAlign: TextAlign.center,
      info.teamName,
      style: const TextStyle(
        color: Colors.white,
      ),
    );

    Widget tOnWidget = Text(
      textAlign: TextAlign.center,
      info.onTable,
      style: const TextStyle(
        color: Colors.white,
      ),
    );

    Widget a = isLeft ? tOnWidget : tNumWidget;
    Widget b = tNaWidget;
    Widget c = isLeft ? tNumWidget : tOnWidget;

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            child: a,
          ),
        ),
        Expanded(
          flex: 3,
          child: b,
        ),
        Expanded(
          flex: 1,
          child: c,
        ),
      ],
    );
  }

  Widget _buildFooterSide({
    required BuildContext context,
    required List<_MatchInfoTableData> teamsInfo,
    bool isLeft = true,
  }) {
    EdgeInsetsGeometry margin = isLeft ? const EdgeInsets.only(right: 10) : const EdgeInsets.only(left: 10);
    double childHeight = 50;
    double height = childHeight;

    if (teamsInfo.length > 2) {
      height = childHeight * 3;
    } else if (teamsInfo.length > 1) {
      height = childHeight * 2;
    }

    return Container(
      width: 500,
      height: height, // 144 real/150 with border
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AnimatedInfiniteVerticalList(
          children: List<Widget>.generate(teamsInfo.length, (index) {
            return Container(
              height: childHeight,
              color: _getBackgroundColor(index, isLeft: isLeft),
              child: _buildInfoRow(context, teamsInfo[index], isLeft: isLeft),
            );
          }),
          childHeight: childHeight,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector2<TeamsProvider, TmsLocalStorageProvider, List<_MatchInfoTableData>>(
      selector: (context, teamsProvider, localStorageProvider) {
        List<_MatchInfoTableData> info = data.value.loadedMatches.expand((m) {
          return m.gameMatchTables.map((t) {
            return _MatchInfoTableData(
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
      builder: (context, teamsInfo, _) {
        List<_MatchInfoTableData> leftTeamsInfo = [];
        List<_MatchInfoTableData> rightTeamsInfo = [];

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
              // color: Colors.red,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFooterSide(context: context, isLeft: true, teamsInfo: leftTeamsInfo),
                  _buildFooterSide(context: context, isLeft: false, teamsInfo: rightTeamsInfo),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
