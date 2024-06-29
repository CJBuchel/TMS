import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/utils/color_modifiers.dart';

class TableItem extends StatelessWidget {
  final GameMatchTable table;
  final Color? backgroundColor;

  const TableItem({
    required this.table,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.blue),
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
          color: lighten(backgroundColor ?? Colors.blueGrey, 0.05),
        ),
        child: Column(
          children: [
            Text(table.table),
            const SizedBox(height: 10),
            Text(table.teamNumber, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
