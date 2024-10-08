import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/providers/auth_provider.dart';
import 'package:tms/providers/robot_game_providers/game_scoring_provider.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/widgets/buttons/live_checkbox.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/game_scoring_widget.dart';

class AddGameScoreDialog {
  final String teamId;

  AddGameScoreDialog({
    required this.teamId,
  });

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _roundController = TextEditingController(text: '1');
  bool _noShow = false;

  Widget _textCell(String title, String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
          ),
          Text(
            text,
            style: const TextStyle(color: Colors.green),
            softWrap: true,
          ),
        ],
      ),
    );
  }

  void _addAnswers(BuildContext context) {
    ConfirmDialog(
      style: ConfirmDialogStyle.success(
        title: 'Add Answers',
        message: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          child: GameScoringWidget(
            scrollController: _scrollController,
          ),
        ),
      ),
    ).show(context);
  }

  void show(BuildContext context) {
    TmsLogger().i('Resetting the GameScoringProvider');
    Provider.of<GameScoringProvider>(context, listen: false).resetAnswers();

    ConfirmFutureDialog(
      onStatusConfirmFuture: () {
        return Provider.of<GameScoringProvider>(context, listen: false).submitScoreSheet(
          table: "",
          teamNumber: Provider.of<TeamsProvider>(context, listen: false).getTeamById(teamId).teamNumber,
          referee: Provider.of<AuthProvider>(context, listen: false).username,
          round: int.tryParse(_roundController.text) ?? 1,
          noShow: _noShow,
        );
      },
      style: ConfirmDialogStyle.success(
        title: 'Add Score',
        message: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // info
            Selector<TeamsProvider, Team>(
              selector: (context, provider) => provider.getTeamById(teamId),
              builder: (context, team, child) {
                return _textCell('Team:', "${team.teamNumber} | ${team.name}");
              },
            ),
            Selector<GameScoringProvider, int>(
              selector: (context, provider) => provider.score,
              builder: (context, score, child) {
                return _textCell('Score:', score.toString());
              },
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("No Show:"),
                  LiveCheckbox(
                    defaultValue: false,
                    onChanged: (value) => _noShow = value,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _roundController,
                decoration: const InputDecoration(
                  labelText: 'Round',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Add Score Sheet"),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: () => _addAnswers(context),
                ),
              ],
            ),
          ],
        ),
      ),
    ).show(context);
  }
}
