import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/widgets/buttons/live_checkbox.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
import 'package:tms/widgets/dialogs/dialog_style.dart';

class EditMatchButton extends StatelessWidget {
  final GameMatch match;
  EditMatchButton({
    required this.match,
  });

  final ValueNotifier<bool> _matchComplete = ValueNotifier(false);
  final ValueNotifier<List<bool>> _gameMatchTableScoresSubmitted =
      ValueNotifier([]);

  List<Widget> _buildGameTableDialogs() {
    _gameMatchTableScoresSubmitted.value = List<bool>.generate(
      match.gameMatchTables.length,
      (int index) => match.gameMatchTables[index].scoreSubmitted,
    );
    return List<Widget>.generate(
      _gameMatchTableScoresSubmitted.value.length,
      (int index) {
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("[${match.gameMatchTables[index].table}] Score Submitted"),
              LiveCheckbox(
                defaultValue: _gameMatchTableScoresSubmitted.value[index],
                onChanged: (bool newValue) {
                  // check if index exists
                  _gameMatchTableScoresSubmitted.value[index] = newValue;
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogMessage() {
    _matchComplete.value = match.completed;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // match complete
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Match Complete"),
              LiveCheckbox(
                defaultValue: _matchComplete.value,
                onChanged: (bool newValue) => _matchComplete.value = newValue,
              ),
            ],
          ),
        ),
        // divider
        const Divider(),
        // game tables
        ..._buildGameTableDialogs(),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    ConfirmFutureDialog(
      style: DialogStyle.warn(
        title: "Edit match ${match.matchNumber}",
        message: _buildDialogMessage(),
      ),
      onStatusConfirmFuture: () {
        List<GameMatchTable> updatedTables = List<GameMatchTable>.generate(
          match.gameMatchTables.length,
          (int index) {
            return GameMatchTable(
              table: match.gameMatchTables[index].table,
              scoreSubmitted: _gameMatchTableScoresSubmitted.value[index],
              teamNumber: match.gameMatchTables[index].teamNumber,
              checkInStatus: match.gameMatchTables[index].checkInStatus,
            );
          },
        );

        GameMatch updatedMatch = GameMatch(
          matchNumber: match.matchNumber,
          startTime: match.startTime,
          endTime: match.endTime,
          gameMatchTables: updatedTables,
          completed: _matchComplete.value,
          category: match.category,
          queueState: match.queueState,
        );

        // update the match

        return Provider.of<GameMatchProvider>(context, listen: false)
            .insertGameMatch(
          match.matchNumber,
          updatedMatch,
        );
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.orange),
        overlayColor: WidgetStateProperty.all(Colors.orange[400]),
        splashFactory: NoSplash.splashFactory,
      ),
      onPressed: () => _showEditDialog(context),
      icon: const Icon(Icons.edit, color: Colors.black),
    );
  }
}
