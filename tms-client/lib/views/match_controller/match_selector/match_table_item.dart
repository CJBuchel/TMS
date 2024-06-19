import 'package:flutter/material.dart';
import 'package:tms/schemas/database_schema.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/utils/tms_date_time.dart';
import 'package:tms/widgets/expandable/expandable_tile.dart';

class MatchTableItem extends StatelessWidget {
  final GameMatch match;
  final Color? backgroundColor;
  final Function(bool)? onChange;
  final ExpansionController? controller;

  const MatchTableItem({
    Key? key,
    required this.match,
    this.backgroundColor,
    this.controller,
    this.onChange,
  }) : super(key: key);

  Widget _leading() {
    return SizedBox(
      width: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(Icons.sports_esports),
          const SizedBox(width: 10),
          Column(
            children: [
              Text("#${match.matchNumber}"),
              const SizedBox(height: 10),
              Text(tmsDateTimeToString(match.startTime), style: const TextStyle(fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _trailing() {
    // return const Icon(Icons.chevron_right);
    return ValueListenableBuilder(
      valueListenable: controller ?? ExpansionController(),
      builder: (context, isExpanded, child) {
        return isExpanded ? const Icon(Icons.expand_more) : const Icon(Icons.chevron_right);
      },
    );
  }

  Widget _tableInfo(GameMatchTable table, Color borderColor) {
    return Expanded(
      flex: 1,
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.blue),
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
          color: lighten(backgroundColor ?? Colors.white, 0.05),
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

  Widget _central(Color borderColor) {
    List<Widget> children = [];

    for (GameMatchTable table in match.gameMatchTables) {
      children.add(_tableInfo(table, borderColor));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.black;

    return Card(
      margin: const EdgeInsets.all(5),
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor),
      ),
      child: ExpandableTile(
        controller: controller,
        onChange: onChange,
        header: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // leading
              _leading(),

              // central/main info
              Expanded(
                child: _central(borderColor),
              ),

              // trailing
              _trailing(),
            ],
          ),
        ),
        body: _central(borderColor),
      ),
    );
  }
}
