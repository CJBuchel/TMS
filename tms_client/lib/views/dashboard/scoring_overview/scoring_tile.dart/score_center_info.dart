import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_score_sheet.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/utils/color_modifiers.dart';

class ScoreCenterInfo extends StatelessWidget {
  final Color backgroundColor;
  final GameScoreSheet teamScoreSheet;

  const ScoreCenterInfo({
    required this.backgroundColor,
    required this.teamScoreSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<TeamsProvider, String>(
      selector: (context, p) =>
          p.getTeamById(teamScoreSheet.teamRefId).teamNumber,
      builder: (context, teamNumber, _) {
        return Row(
          children: [
            // Team info
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                  color: lighten(backgroundColor, 0.05),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      // color the top of the container
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "Table | Team",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // score
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        teamScoreSheet.table.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // const SizedBox(height: 10),
                    // gp
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        teamNumber,
                        style: const TextStyle(
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Team score
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                  color: lighten(backgroundColor, 0.05),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      // color the top of the container
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "Score | GP",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // score
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        teamScoreSheet.score.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // const SizedBox(height: 10),
                    // gp
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        teamScoreSheet.gp.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
