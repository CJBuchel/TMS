import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/utils/color_modifiers.dart';

class TableItem extends StatelessWidget {
  final bool isMatchComplete;
  final GameMatchTable table;
  final Color? backgroundColor;
  final Color submittedColor;

  const TableItem({
    required this.isMatchComplete,
    required this.table,
    this.backgroundColor,
    this.submittedColor = Colors.green,
  });

  Color _getBackgroundColor() {
    Color defaultColor = backgroundColor ?? Colors.blueGrey;

    if (isMatchComplete) {
      return table.scoreSubmitted ? submittedColor : Colors.red;
    } else {
      return table.scoreSubmitted ? submittedColor : defaultColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color? fontColor = table.scoreSubmitted ? Colors.black : null;

    return Expanded(
      flex: 1,
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.blue),
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
          color: lighten(_getBackgroundColor(), 0.05),
        ),
        child: Column(
          children: [
            Text(
              table.table,
              style: TextStyle(fontSize: 12, color: fontColor),
            ),
            const SizedBox(height: 10),
            Text(
              table.teamNumber,
              style: TextStyle(fontSize: 12, color: fontColor),
            ),
          ],
        ),
      ),
    );
  }
}
