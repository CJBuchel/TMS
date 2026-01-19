import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/colors.dart';
import 'package:tms_client/generated/db/db.pb.dart';
import 'package:tms_client/providers/table_name_provider.dart';
import 'package:tms_client/providers/team_provider.dart';
import 'package:tms_client/utils/time.dart';
import 'package:tms_client/views/match_controller/match_selector/tile_table_assignment.dart';
import 'package:tms_client/widgets/time_until.dart';

class MatchTile extends ConsumerWidget {
  final String matchKey;
  final GameMatch match;

  const MatchTile({super.key, required this.matchKey, required this.match});

  String convertTimeToString(DateTime time) {
    int hour = time.hour;
    String period = hour >= 12 ? 'PM' : 'AM';

    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Widget tableAssignment(WidgetRef ref, TableAssignment assignment) {
    final team = ref.watch(teamProvider(assignment.teamId));
    final tableName = ref.watch(tableNameProvider(assignment.tableId));
    return TileTableAssignment(
      assignment: assignment,
      team: team,
      tableName: tableName,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startTime = match.startTime.toNextOccurrence();
    final startTimeStr = convertTimeToString(startTime);

    return ExpansionTile(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      collapsedBackgroundColor: Theme.of(
        context,
      ).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.black),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.black),
      ),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          match.matchNumber,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  startTimeStr,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TimeUntil(
                  time: startTime,
                  timeOfDayOnly: true,
                  positiveStyle: TextStyle(
                    color: supportSuccessColor,
                    fontSize: 12,
                  ),
                  negativeStyle: TextStyle(
                    color: supportErrorColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 5,
            child: Row(
              children: match.assignments
                  .map(
                    (assignment) => Expanded(
                      flex: 1,
                      child: tableAssignment(ref, assignment),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
      children: const [Text('Expanded')],
    );
  }
}
