import 'package:flutter/material.dart';
import 'package:tms/schemas/database_schema.dart';
import 'package:tms/views/match_controller/match_selector/match_row/expanded_row_body/edit_match_tables.dart';
import 'package:tms/views/match_controller/match_selector/match_row/expanded_row_body/stage_match_buttons.dart';

class ExpandedRowBody extends StatelessWidget {
  final GameMatch match;

  const ExpandedRowBody({
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EditMatchTables(),
        Row(
          children: [
            Expanded(child: StageMatchButtons(match: match)),
          ],
        ),
      ],
    );
  }
}
