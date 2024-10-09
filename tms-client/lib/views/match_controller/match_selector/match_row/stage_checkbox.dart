import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/robot_game_providers/game_match_status_provider.dart';
import 'package:tms/widgets/buttons/live_checkbox.dart';

class StageCheckbox extends StatelessWidget {
  final GameMatch match;
  final bool canStage;
  final bool isStaged;

  const StageCheckbox({
    required this.match,
    required this.canStage,
    required this.isStaged,
  });

  @override
  Widget build(BuildContext context) {
    if (canStage || isStaged) {
      return LiveCheckbox(
        color: Colors.purpleAccent,
        defaultValue: isStaged,
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
  }
}
