import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/providers/robot_game_providers/game_scoring_provider.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';

class SubmitAnswersButton extends StatelessWidget {
  final double buttonHeight;
  final ScrollController? scrollController;
  final Team? team;
  final GameMatch? match;
  final int round;
  final String table;
  final String referee;

  SubmitAnswersButton({
    Key? key,
    this.buttonHeight = 40,
    this.scrollController,
    this.team,
    this.match,
    required this.round,
    required this.table,
    required this.referee,
  }) : super(key: key);

  void _submitAnswersDialog(BuildContext context) {
    ConfirmFutureDialog(
      style: ConfirmDialogStyle.success(
        title: "Submit Answers",
        message: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Submit answers for match ${match?.matchNumber}, team ${team?.teamNumber}?"),
            const SizedBox(height: 10),
            const Text("This action cannot be undone."),
          ],
        ),
      ),
      onStatusConfirmFuture: () {
        if (team != null && match != null) {
          return Provider.of<GameScoringProvider>(context, listen: false).submitScoreSheet(
            table: table,
            round: round,
            teamNumber: team!.teamNumber,
            matchNumber: match!.matchNumber,
            referee: referee,
          );
        } else {
          return Future.value(HttpStatus.badRequest);
        }
      },
      onFinish: (status) {
        if (status == HttpStatus.ok) {
          if (scrollController?.hasClients ?? false) {
            scrollController?.animateTo(
              0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
          Provider.of<GameScoringProvider>(context, listen: false).resetAnswers();
        }
      },
    ).show(context);
  }

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
                _submitAnswersDialog(context);
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
