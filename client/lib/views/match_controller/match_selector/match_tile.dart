import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/generated/db/db.pb.dart';
import 'package:tms_client/utils/time.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startTime = match.startTime.toNextOccurrence();
    final startTimeStr = convertTimeToString(startTime);

    return ExpansionTile(
      leading: Column(
        children: [
          Text(startTimeStr),
          TimeUntil(
            time: startTime,
            timeOfDayOnly: true,
            positiveStyle: TextStyle(color: Colors.green),
            negativeStyle: TextStyle(color: Colors.red),
          ),
        ],
      ),
      title: Text(match.matchNumber),
      subtitle: Text('Subtitle'),
      trailing: Text('Trailing'),
      children: [Text('Expanded')],
    );
  }
}
