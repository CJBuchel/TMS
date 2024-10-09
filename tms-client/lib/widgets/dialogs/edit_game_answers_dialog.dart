import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_score_sheet.dart';
import 'package:tms/generated/infra/fll_infra/question.dart';
import 'package:tms/providers/robot_game_providers/game_scoring_provider.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/game_scoring_widget.dart';

class EditGameAnswersDialog {
  final Function(List<QuestionAnswer> answers, int score, String privateComment) onConfirm;
  final GameScoreSheet scoreSheet;

  EditGameAnswersDialog({
    required this.onConfirm,
    required this.scoreSheet,
  });

  final ScrollController _scrollController = ScrollController();

  void show(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width * 0.8;
    final dialogHeight = screenSize.height * 0.8;

    ConfirmDialog(
      onConfirm: () {
        onConfirm(
          Provider.of<GameScoringProvider>(context, listen: false).answers,
          Provider.of<GameScoringProvider>(context, listen: false).score,
          Provider.of<GameScoringProvider>(context, listen: false).privateComment,
        );
      },
      style: ConfirmDialogStyle.warn(
        title: 'Edit Answers',
        message: Container(
          width: dialogWidth,
          height: dialogHeight,
          child: GameScoringWidget(
            scrollController: _scrollController,
            scoreSheet: scoreSheet,
          ),
        ),
      ),
    ).show(context);
  }
}
