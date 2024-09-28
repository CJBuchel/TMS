import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_score_sheet.dart';
import 'package:tms/generated/infra/fll_infra/question.dart';
import 'package:tms/models/team_score_sheet.dart';
import 'package:tms/providers/auth_provider.dart';
import 'package:tms/providers/robot_game_providers/game_scoring_provider.dart';
import 'package:tms/services/game_scoring_service.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/views/teams/team_editor/team_scores/on_edit_answers.dart';
import 'package:tms/widgets/buttons/live_checkbox.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
import 'package:collection/collection.dart';

class OnEditScore {
  final TeamScoreSheet score;

  OnEditScore({
    required this.score,
  });

  final TextEditingController _tableController = TextEditingController();
  final TextEditingController _refereeController = TextEditingController();
  final TextEditingController _matchNumberController = TextEditingController();
  final TextEditingController _roundNumberController = TextEditingController();
  final ValueNotifier<List<QuestionAnswer>> _answers = ValueNotifier([]);
  final ValueNotifier<int> _score = ValueNotifier(0);
  final ValueNotifier<String> _privateComment = ValueNotifier('');
  final ValueNotifier<bool> _noShow = ValueNotifier(false);
  final ValueNotifier<bool> _isAgnostic = ValueNotifier(false);

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
    // reset the provider
    TmsLogger().i('Resetting the GameScoringProvider');
    Provider.of<GameScoringProvider>(context, listen: false).answers = score.scoreSheet.scoreSheetAnswers;
    Provider.of<GameScoringProvider>(context, listen: false).score = score.scoreSheet.score;
    Provider.of<GameScoringProvider>(context, listen: false).privateComment = score.scoreSheet.privateComment;
    // setup the initial values
    _tableController.text = score.scoreSheet.table;
    _refereeController.text = score.scoreSheet.referee;
    _matchNumberController.text = score.scoreSheet.matchNumber ?? '';
    _roundNumberController.text = score.scoreSheet.round.toString();
    _answers.value = score.scoreSheet.scoreSheetAnswers;
    _score.value = score.scoreSheet.score;
    _privateComment.value = score.scoreSheet.privateComment;
    _noShow.value = score.scoreSheet.noShow;
    _isAgnostic.value = score.scoreSheet.isAgnostic;

    ConfirmFutureDialog(
      onStatusConfirmFuture: () {
        // find gp
        String gp = Provider.of<GameScoringProvider>(context, listen: false).answers.firstWhereOrNull((element) {
              return element.questionId == 'gp';
            })?.answer ??
            score.scoreSheet.gp;

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
          noShow: _noShow.value,
          isAgnostic: _isAgnostic.value,
          modified: true,
          modifiedBy: Provider.of<AuthProvider>(context, listen: false).username,
        );
        return GameScoringService().insertScoreSheet(
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
            _textCell('Timestamp: ', score.scoreSheet.timestamp.toString()),
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
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
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
                    onChanged: (value) => _noShow.value = value,
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
                    onChanged: (value) => _isAgnostic.value = value,
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
                    onPressed: () => OnEditAnswers(
                      scoreSheet: score.scoreSheet,
                      onConfirm: (answers, score, privateComment) {
                        _answers.value = answers;
                        _score.value = score;
                        _privateComment.value = privateComment;
                      },
                    ).call(context),
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
