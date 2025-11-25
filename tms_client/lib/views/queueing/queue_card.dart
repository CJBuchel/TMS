import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/tms_time/tms_date_time.dart';
import 'package:tms/widgets/timers/time_until.dart';

class QueueCard extends StatelessWidget {
  final GameMatch match;
  final List<GameMatch> loadedMatches;
  final Color statusColor;

  const QueueCard({
    Key? key,
    required this.match,
    required this.loadedMatches,
    this.statusColor = Colors.blue,
  }) : super(key: key);

  Widget ttl(TmsDateTime time, bool completed) {
    // Placeholder for TTL calculation

    if (completed) {
      return const Text(
        'TTL: CMP',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    }

    return Row(
      children: [
        const Text(
          'TTL: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        TimeUntil(
          time: time,
          positiveStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          negativeStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.red,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 35.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ttl(match.startTime, match.completed),
              ],
            ),
          ),

          // Main body
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).cardColor,
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Match Number
                        Text(
                          '#${match.matchNumber}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        // Time
                        Text(
                          match.startTime.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Loaded Matches: ${loadedMatches.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ]),
          )
        ],
      ),
    );
  }
}
