import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/game_score_sheet.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/game_scoring_widget.dart';

class OnEditAnswers {
  final GameScoreSheet scoreSheet;

  OnEditAnswers({required this.scoreSheet});

  final ScrollController _scrollController = ScrollController();

  void call(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width * 0.8;
    final dialogHeight = screenSize.height * 0.8;

    ConfirmDialog(
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
