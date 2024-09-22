import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_score_sheet.dart';
import 'package:tms/models/team_score_sheet.dart';
import 'package:tms/providers/auth_provider.dart';
import 'package:tms/providers/robot_game_providers/game_scoring_provider.dart';
import 'package:tms/services/game_scoring_service.dart';
import 'package:tms/utils/tms_time_utils.dart';
import 'package:tms/views/teams/team_editor/team_scores/on_edit_answers.dart';
import 'package:tms/widgets/buttons/live_checkbox.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';

class OnEditScore {
  final TeamScoreSheet score;

  OnEditScore({
    required this.score,
  });

  final TextEditingController _tableController = TextEditingController();
  final TextEditingController _refereeController = TextEditingController();
  final TextEditingController _matchNumberController = TextEditingController();
  final TextEditingController _roundNumberController = TextEditingController();

  bool _noShow = false;
  bool _isAgnostic = false;

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

  void call(BuildContext context) {
    _tableController.text = score.scoreSheet.table;
    _refereeController.text = score.scoreSheet.referee;
    _matchNumberController.text = score.scoreSheet.matchNumber ?? '';
    _roundNumberController.text = score.scoreSheet.round.toString();

    ConfirmFutureDialog(
      onStatusConfirmFuture: () {
        // find gp
        String gp = Provider.of<GameScoringProvider>(context, listen: false).answers.firstWhere((element) {
          return element.questionId == 'gp';
        }).answer;

        // create updated score sheet
        GameScoreSheet updatedScoreSheet = GameScoreSheet(
          // non edit fields
          blueprintTitle: score.scoreSheet.blueprintTitle,
          teamRefId: score.scoreSheet.teamRefId,
          timestamp: score.scoreSheet.timestamp,
          // modified fields
          gp: gp,
          scoreSheetAnswers: Provider.of<GameScoringProvider>(context, listen: false).answers,
          score: Provider.of<GameScoringProvider>(context, listen: false).score,
          privateComment: Provider.of<GameScoringProvider>(context, listen: false).privateComment,
          round: int.tryParse(_roundNumberController.text) ?? score.scoreSheet.round,
          table: _tableController.text,
          referee: _refereeController.text,
          noShow: _noShow,
          isAgnostic: _isAgnostic,
          modified: true,
          modifiedBy: Provider.of<AuthProvider>(context, listen: false).username,
        );
        return GameScoringService().updateScoreSheet(
          score.scoreSheetId,
          updatedScoreSheet,
        );
      },
      style: ConfirmDialogStyle.warn(
        title: 'Edit Score',
        message: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // non edit fields
            _textCell('Blueprint: ', score.scoreSheet.blueprintTitle),
            _textCell('Timestamp: ', tmsDateTimeToString(score.scoreSheet.timestamp)),
            _textCell('GP: ', score.scoreSheet.gp),
            _textCell('Round: ', score.scoreSheet.round.toString()),
            _textCell('Private Comment: ', score.scoreSheet.privateComment),
            _textCell('Modified: ', score.scoreSheet.modified.toString()),
            _textCell('Modified By: ', score.scoreSheet.modifiedBy ?? ''),
            _textCell('Score: ', score.scoreSheet.score.toString()),
            // divider
            const Divider(),
            // edit fields
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextField(
                decoration: const InputDecoration(labelText: 'Table'),
                controller: _tableController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextField(
                decoration: const InputDecoration(labelText: 'Referee'),
                controller: _refereeController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextField(
                decoration: const InputDecoration(labelText: 'Match Number'),
                controller: _matchNumberController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextField(
                decoration: const InputDecoration(labelText: 'Round'),
                controller: _roundNumberController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('No Show: '),
                  LiveCheckbox(
                    defaultValue: score.scoreSheet.noShow,
                    onChanged: (value) => _noShow = value,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Agnostic: '),
                  LiveCheckbox(
                    defaultValue: score.scoreSheet.isAgnostic,
                    onChanged: (value) => _isAgnostic = value,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Answers: '),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => OnEditAnswers(scoreSheet: score.scoreSheet).call(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).show(context);
  }
}
