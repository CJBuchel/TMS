import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/providers/game_scoring_provider.dart';

class SubmitAnswersButton extends StatelessWidget {
  final double buttonHeight;
  final ScrollController? scrollController;
  final Team? team;
  final GameMatch? match;

  SubmitAnswersButton({
    Key? key,
    this.buttonHeight = 40,
    this.scrollController,
    this.team,
    this.match,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // disable if team or match is null
    bool disabled = team == null || match == null;
    return Selector<GameScoringProvider, bool>(
      selector: (context, provider) => provider.isValid(),
      builder: (context, isValid, _) {
        bool isDisabled = disabled || !isValid;

        return Container(
          height: buttonHeight,
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (!isDisabled) {
                // @TODO send answers to server
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: isDisabled ? Colors.grey : Colors.green,
            ),
            label: const Text("Submit"),
          ),
        );
      },
    );
  }
}
