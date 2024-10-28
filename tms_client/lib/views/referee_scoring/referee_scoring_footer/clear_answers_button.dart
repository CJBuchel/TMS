import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/robot_game_providers/game_scoring_provider.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/dialog_style.dart';

class ClearAnswersButton extends StatelessWidget {
  final double buttonHeight;
  final ScrollController? scrollController;

  ClearAnswersButton({
    Key? key,
    this.buttonHeight = 40,
    this.scrollController,
  }) : super(key: key);

  void _onClearButton(BuildContext context) {
    ConfirmDialog(
      style: DialogStyle.error(
        title: "Clear Answers",
        message: const Text("Are you sure you want to clear all answers?"),
      ),
      onConfirm: () {
        Provider.of<GameScoringProvider>(context, listen: false).resetAnswers();
        if (scrollController?.hasClients ?? false) {
          scrollController?.animateTo(
            0.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: buttonHeight,
      padding: const EdgeInsets.only(left: 10, right: 15),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.clear),
        onPressed: () => _onClearButton(context),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red,
        ),
        label: const Text("Clear"),
      ),
    );
  }
}
