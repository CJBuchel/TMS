import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/views/match_controller/match_selector/match_row/expanded_row_body/edit_match_tables.dart';
import 'package:tms/views/match_controller/match_selector/match_row/expanded_row_body/stage_match_buttons.dart';

class ExpandedRowBody extends StatelessWidget {
  final GameMatch match;
  final List<GameMatch> loadedMatches;

  const ExpandedRowBody({
    required this.match,
    required this.loadedMatches,
  });

  Widget _stageButtons(BuildContext context) {
    if (!loadedMatches.isNotEmpty) {
      return Row(
        children: [
          Expanded(child: StageMatchButtons(match: match)),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EditMatchTables(),
        _stageButtons(context),
      ],
    );
  }
}
