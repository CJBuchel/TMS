import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/game_score_sheet.dart';

class TeamScoreSheetTags extends StatelessWidget {
  final GameScoreSheet gameScoreSheet;

  TeamScoreSheetTags({required this.gameScoreSheet});

  Widget _containerTag(String label, Color color) {
    // create outline border container with same colored text
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (gameScoreSheet.isAgnostic) _containerTag('AG', Colors.cyan),
        if (gameScoreSheet.noShow) _containerTag('NS', Colors.orange),
        if (gameScoreSheet.modified) _containerTag('MOD', Colors.pink),
      ],
    );
  }
}
