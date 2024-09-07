import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_status_provider.dart';
import 'package:tms/widgets/buttons/live_checkbox.dart';

class StageCheckbox extends StatelessWidget {
  final GameMatch match;

  const StageCheckbox({
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return Selector2<GameMatchStatusProvider, GameMatchProvider, ({bool canStage, bool isStaged})>(
      selector: (context, statusProvider, gameMatchProvider) {
        return (
          canStage: statusProvider.canStageMatch(match.matchNumber, gameMatchProvider.matches),
          isStaged: statusProvider.isMatchStaged(match.matchNumber),
        );
      },
      builder: (context, data, _) {
        if (data.canStage || data.isStaged) {
          return LiveCheckbox(
            color: Colors.purpleAccent,
            defaultValue: data.isStaged,
            onChanged: (value) {
              if (value) {
                Provider.of<GameMatchStatusProvider>(context, listen: false).addMatchToStage(match.matchNumber);
              } else {
                Provider.of<GameMatchStatusProvider>(context, listen: false).removeMatchFromStage(match.matchNumber);
              }
            },
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
