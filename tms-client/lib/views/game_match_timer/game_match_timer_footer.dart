import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/views/game_match_timer/timer_match_data.dart';

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

  @override
  Widget build(BuildContext context) {
    return Selector<TeamsProvider, List<_MatchInfoTableData>>(
      selector: (context, provider) {
        return data.value.loadedMatches.expand((m) {
          return m.gameMatchTables.map((t) {
            return _MatchInfoTableData(
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
          decoration: BoxDecoration(
            color: Colors.blueGrey[900],
            // borderRadius: BorderRadius.circular(10),
            border: const Border(
              top: BorderSide(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    // borderRadius: BorderRadius.circular(10),
                    border: const Border(
                      right: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                  child: const Center(child: Text("Left")),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    // borderRadius: BorderRadius.circular(10),
                    border: const Border(
                      left: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                  child: const Center(child: Text("Right")),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// return AnimatedInfiniteVerticalList(
//   childHeight: 100,
//   children: List<Widget>.generate(
//     42,
//     (index) => Container(
//       color: index.isEven ? Colors.deepPurple[900] : Colors.deepPurple[800],
//       height: 100,
//       child: Text(
//         'Item $index',
//         style: const TextStyle(
//           fontSize: 20,
//         ),
//       ),
//     ),
//   ),
// );
