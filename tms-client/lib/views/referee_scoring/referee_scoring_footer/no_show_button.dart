import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/providers/robot_game_providers/game_scoring_provider.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';

class NoShowButton extends StatelessWidget {
  final double buttonHeight;
  final ScrollController? scrollController;
  final Team? team;
  final GameMatch? match;
  final int round;
  final String table;
  final String referee;

  NoShowButton({
    Key? key,
    this.buttonHeight = 40,
    this.scrollController,
    this.team,
    this.match,
    required this.round,
    required this.table,
    required this.referee,
  }) : super(key: key);

  void _submitNoShowDialog(BuildContext context) {
    ConfirmFutureDialog(
      style: ConfirmDialogStyle.warn(
        title: "No Show",
        message: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Are you sure you want to mark '${team?.name}' as a no show for match ${match?.matchNumber}?"),
            const SizedBox(height: 10),
            const Text("This action cannot be undone."),
          ],
        ),
      ),
      onStatusConfirmFuture: () => Provider.of<GameScoringProvider>(context, listen: false).submitNoShow(
        table: table,
        teamNumber: team!.teamNumber,
        round: round,
        matchNumber: match!.matchNumber,
      ),
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

    return Container(
      height: buttonHeight,
      padding: const EdgeInsets.only(left: 15, right: 10),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.no_accounts),
        onPressed: () {
          if (!disabled && team != null && match != null) {
            _submitNoShowDialog(context);
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: disabled ? Colors.grey : Colors.orange,
        ),
        label: const Text("No Show"),
      ),
    );
  }
}
