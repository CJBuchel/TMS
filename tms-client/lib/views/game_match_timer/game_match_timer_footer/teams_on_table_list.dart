import 'package:flutter/material.dart';
import 'package:tms/models/team_on_table_info.dart';
import 'package:tms/widgets/team_widgets/team_on_table_row.dart';
import 'package:tms/widgets/animated/infinite_vertical_list.dart';

class TeamsOnTableList extends StatelessWidget {
  final List<TeamOnTableInfo> teamsInfo;
  final bool isLeft;

  const TeamsOnTableList({
    Key? key,
    required this.teamsInfo,
    required this.isLeft,
  }) : super(key: key);

  Color? _getBackgroundColor(int index, {bool isLeft = true}) {
    if (isLeft) {
      return index.isEven ? Colors.deepPurple[900] : Colors.deepPurple[800];
    } else {
      return index.isEven ? Colors.pink[900] : Colors.pink[800];
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: TeamOnTableRow(info: teamsInfo[index], isLeft: isLeft),
            );
          }),
          childHeight: childHeight,
        ),
      ),
    );
  }
}
