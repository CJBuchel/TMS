import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/sorter_util.dart';

class MatchInfoTable extends StatelessWidget {
  final List<GameMatch> matches;
  final List<Team> teams;
  const MatchInfoTable({Key? key, required this.matches, required this.teams}) : super(key: key);

  Widget _buildCell(String text, {Color? backgroundColor, Color? textColor, double? width}) {
    return Container(
      width: width,
      color: backgroundColor,
      child: Center(child: Text(text, style: TextStyle(color: textColor, overflow: TextOverflow.ellipsis))),
    );
  }

  Widget _buildRow(List<Team> teams, GameMatch match, Color rowColor, double rowHeight) {
    Team? firstTeam;
    Team? secondTeam;

    for (var team in teams) {
      if (team.teamNumber == match.onTableFirst.teamNumber) {
        firstTeam = team;
      }
      if (team.teamNumber == match.onTableSecond.teamNumber) {
        secondTeam = team;
      }
    }

    return Container(
      height: rowHeight,
      color: rowColor,
      child: LayoutBuilder(builder: (context, constraints) {
        int cells = 5;
        double cellWidth = constraints.maxWidth / cells;
        return Row(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // start time, table 1, team 1, table2 team 2
            _buildCell(
              match.startTime,
              backgroundColor: rowColor,
              textColor: Colors.black,
              width: cellWidth,
            ),

            _buildCell(
              firstTeam != null ? "${firstTeam.teamNumber} | ${firstTeam.teamName}" : "",
              backgroundColor: rowColor,
              textColor: Colors.black,
              width: cellWidth,
            ),

            _buildCell(
              "On Table: ${match.onTableFirst.table}",
              backgroundColor: rowColor,
              textColor: Colors.black,
              width: cellWidth,
            ),

            _buildCell(
              secondTeam != null ? "${secondTeam.teamNumber} | ${secondTeam.teamName}" : "",
              backgroundColor: rowColor,
              textColor: Colors.black,
              width: cellWidth,
            ),

            _buildCell(
              "On Table: ${match.onTableSecond.table}",
              backgroundColor: rowColor,
              textColor: Colors.black,
              width: cellWidth,
            ),
          ],
        );
      }),
    );
  }

  Widget getTable() {
    // get max height using layout builder
    List<GameMatch> futureMatches = [];
    for (var match in matches) {
      if (!match.complete) {
        futureMatches.add(match);
      }
    }

    futureMatches = sortMatchesByTime(futureMatches);

    int itemCount = 3;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (futureMatches.isEmpty || teams.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return SizedBox(
            height: constraints.maxHeight,
            child: ListView.builder(
              itemCount: itemCount,
              itemBuilder: (context, index) {
                return _buildRow(teams, futureMatches[index], index.isEven ? Colors.white : Colors.grey[300]!, constraints.maxHeight / itemCount);
              },
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return getTable();
  }
}
