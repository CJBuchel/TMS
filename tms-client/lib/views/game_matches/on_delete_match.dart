import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';

class OnDeleteGameMatch {
  final String matchNumber;

  OnDeleteGameMatch({
    required this.matchNumber,
  });

  void call(BuildContext context) {
    ConfirmFutureDialog(
      style: ConfirmDialogStyle.error(
        title: "Delete Match $matchNumber",
        message: const Text("Are you sure you want to delete this match?"),
      ),
      onStatusConfirmFuture: () {
        return Provider.of<GameMatchProvider>(context, listen: false).removeGameMatch(matchNumber);
      },
    ).show(context);
  }
}
