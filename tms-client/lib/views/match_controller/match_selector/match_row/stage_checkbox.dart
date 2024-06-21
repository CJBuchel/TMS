import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/game_match_provider.dart';
import 'package:tms/schemas/database_schema.dart';
import 'package:tms/widgets/buttons/live_checkbox.dart';

class StageCheckbox extends StatelessWidget {
  final GameMatch match;

  const StageCheckbox({
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<GameMatchProvider, ({bool canStage, bool isStaged})>(
      selector: (context, provider) {
        return (
          canStage: provider.canStageMatch(match.matchNumber),
          isStaged: provider.isMatchStaged(match.matchNumber),
        );
      },
      builder: (context, data, _) {
        if (data.canStage || data.isStaged) {
          return LiveCheckbox(
            defaultValue: data.isStaged,
            onChanged: (value) {
              if (value) {
                Provider.of<GameMatchProvider>(context, listen: false).addMatchToStage(match.matchNumber);
              } else {
                Provider.of<GameMatchProvider>(context, listen: false).removeMatchFromStage(match.matchNumber);
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
