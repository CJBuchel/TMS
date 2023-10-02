import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/scoreboard/match_loaded_table.dart';

class TimerMatchInfo extends StatelessWidget {
  final List<Team> teams;
  final List<GameMatch> matches;
  final List<OnTable> loadedFirstTables; // first set of tables
  final List<OnTable> loadedSecondTables; // second set of tables
  const TimerMatchInfo({
    Key? key,
    required this.teams,
    required this.matches,
    required this.loadedFirstTables,
    required this.loadedSecondTables,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    width: 1,
                    color: AppTheme.isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
              ),
              width: constraints.maxWidth / 2,
              child: Center(
                child: MatchLoadedTable(teams: teams, tables: loadedFirstTables, autoRowColors: true),
              ),
            ),
            SizedBox(
              width: constraints.maxWidth / 2,
              child: Center(
                child: MatchLoadedTable(teams: teams, tables: loadedSecondTables, autoRowColors: true),
              ),
            ),
          ],
        );
      },
    );
  }
}
