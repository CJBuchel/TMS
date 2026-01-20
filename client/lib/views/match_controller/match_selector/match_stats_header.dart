import 'package:flutter/material.dart';
import 'package:tms_client/colors.dart';
import 'package:tms_client/views/match_controller/match_selector/match_stats_popup.dart';
import 'package:tms_client/widgets/dialogs/popup_dialog.dart';

class MatchStatsHeader extends StatelessWidget {
  final int round;
  final int completed;
  final int total;
  final Duration? expectedCycleTime;
  final Duration? lastCycleTime;

  // Repeating colors for rounds
  static const List<Color> roundColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
  ];

  const MatchStatsHeader({
    super.key,
    required this.round,
    required this.completed,
    required this.total,
    this.expectedCycleTime,
    this.lastCycleTime,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final color = roundColors[round % roundColors.length];

    // Determine if last cycle time is ahead or behind expected
    Color? cycleTimeColor;
    if (lastCycleTime != null && expectedCycleTime != null) {
      final diff = lastCycleTime!.inSeconds - expectedCycleTime!.inSeconds;
      if (diff > 30) {
        cycleTimeColor = Colors.red; // Behind schedule
      } else if (diff < -30) {
        cycleTimeColor = Colors.green; // Ahead of schedule
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: const Border(
          bottom: BorderSide(color: Colors.black),
          left: BorderSide(color: Colors.black),
        ),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Stats button
          CircleAvatar(
            backgroundColor: secondaryColor,
            child: IconButton(
              icon: Icon(Icons.bar_chart_rounded, color: Colors.white),
              onPressed: () {
                PopupDialog.info(
                  title: 'Match Statistics',
                  message: MatchStatsPopup(),
                ).show(context);
              },
            ),
          ),
          // Round indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'R${round + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Completed count
          Text(
            '$completed / $total',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          // Cycle time
          if (expectedCycleTime != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cycle Time: ',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  lastCycleTime != null
                      ? _formatDuration(lastCycleTime!)
                      : '--:--',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: cycleTimeColor,
                  ),
                ),
                Text(
                  ' / ${_formatDuration(expectedCycleTime!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
