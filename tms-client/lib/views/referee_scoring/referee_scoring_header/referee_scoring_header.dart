import 'package:flutter/material.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/game_table_info.dart';

class RefereeScoringHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Theme.of(context).cardColor,
        // bottom border only
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey : Colors.transparent,
            width: 1,
          ),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),

      // row of widgets
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // table name
          GameTableInfo(),
          // select table button
          TextButton(
            onPressed: () {
              TmsLogger().f("Nothing");
            },
            child: const Text("Edit"),
          ),
        ],
      ),
    );
  }
}
