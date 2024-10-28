import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_status_provider.dart';
import 'package:tms/views/match_announcer/next_match_info.dart';

class _NextMatchData {
  List<GameMatch> nextMatches;

  _NextMatchData({
    required this.nextMatches,
  });
}

class MatchAnnouncer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [
        ":teams",
        ":robot_game:matches",
      ],
      child: Selector2<GameMatchProvider, GameMatchStatusProvider, _NextMatchData>(
        selector: (_, gmp, gsp) {
          List<GameMatch> loadedMatches = gsp.getLoadedMatches(gmp.matches);

          if (loadedMatches.isEmpty && gmp.nextMatch != null) {
            // get next matches
            return _NextMatchData(
              nextMatches: [gmp.nextMatch!],
            );
          } else {
            // get loaded matches (current match)
            return _NextMatchData(
              nextMatches: loadedMatches,
            );
          }
        },
        builder: (context, data, _) {
          return Column(
            children: [
              // banner (left match info/next/current, right Status time)
              Expanded(
                flex: 1,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).secondaryHeaderColor,
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            "Match 1, 2, 3,",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            "Status: +00:00",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: NextMatchInfo(
                  nextMatches: data.nextMatches,
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Timer Controls",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
