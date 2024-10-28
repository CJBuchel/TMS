import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/views/match_controller/match_selector/match_row/expanded_row_body/delete_match_button.dart';
import 'package:tms/views/match_controller/match_selector/match_row/expanded_row_body/edit_match_button.dart';
import 'package:tms/views/match_controller/match_selector/match_row/expanded_row_body/reschedule_button.dart';
import 'package:tms/views/match_controller/match_selector/match_row/expanded_row_body/stage_match_buttons.dart';

class ExpandedRowBody extends StatelessWidget {
  final GameMatch match;
  final bool isStaged;

  const ExpandedRowBody({
    required this.match,
    required this.isStaged,
  });

  Widget _buttonWrapper(Widget iconButton) {
    return Expanded(
      flex: 1,
      child: Center(
        child: iconButton,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (!match.completed) _buttonWrapper(StageMatchButtons(match: match, isStaged: isStaged)),
          _buttonWrapper(RescheduleButton(match: match)),
          _buttonWrapper(EditMatchButton(match: match)),
          _buttonWrapper(DeleteMatchButton(match: match)),
        ],
      ),
    );
  }
}
