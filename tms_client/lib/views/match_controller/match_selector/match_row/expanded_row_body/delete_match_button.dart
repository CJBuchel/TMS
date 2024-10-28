import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
import 'package:tms/widgets/dialogs/dialog_style.dart';

class DeleteMatchButton extends StatelessWidget {
  final GameMatch match;

  const DeleteMatchButton({
    required this.match,
  });

  void _showConfirmDialog(BuildContext context) {
    ConfirmFutureDialog(
      style: DialogStyle.error(
        title: "Delete Match",
        message: Text("Are you sure you want to delete match ${match.matchNumber}?"),
      ),
      onStatusConfirmFuture: () {
        return Provider.of<GameMatchProvider>(context, listen: false).removeGameMatch(
          match.matchNumber,
        );
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.red),
        overlayColor: WidgetStateProperty.all(Colors.red[400]),
        splashFactory: NoSplash.splashFactory,
      ),
      onPressed: () => _showConfirmDialog(context),
      icon: const Icon(Icons.delete, color: Colors.black),
    );
  }
}
