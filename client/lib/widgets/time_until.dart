import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TimeUntil extends HookConsumerWidget {
  final TextStyle? positiveStyle;
  final String? positiveLeader;
  final TextStyle? negativeStyle;
  final String? negativeLeader;
  final DateTime time;
  final bool timeOfDayOnly;

  const TimeUntil({
    super.key,
    required this.time,
    this.positiveStyle,
    this.positiveLeader = '+',
    this.negativeStyle,
    this.negativeLeader = '-',
    this.timeOfDayOnly = false,
  });

  String _secondsToTimeString(int totalSeconds) {
    int absSeconds = totalSeconds.abs();
    int hours = absSeconds ~/ 3600;
    int minutes = (absSeconds % 3600) ~/ 60;
    int seconds = absSeconds % 60;

    if (hours == 0 && minutes == 0) {
      // Less than a minute: show just seconds
      return '$seconds';
    } else if (hours == 0) {
      // Less than an hour: show M:SS format
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    } else {
      // More than an hour: show H:MM:SS format
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final difference = useState(0);

    useEffect(() {
      final ticker = Ticker((elapsed) {
        final now = DateTime.now();

        if (timeOfDayOnly) {
          // Calculate difference based only on time of day, ignoring date
          final targetSeconds =
              time.hour * 3600 + time.minute * 60 + time.second;
          final nowSeconds = now.hour * 3600 + now.minute * 60 + now.second;
          difference.value = targetSeconds - nowSeconds;
        } else {
          // Normal datetime difference
          difference.value = time.difference(now).inSeconds;
        }
      });

      ticker.start();

      return ticker.dispose;
    }, [time, timeOfDayOnly]);

    final timeString = _secondsToTimeString(difference.value);
    final isNegative = difference.value < 0;

    return RepaintBoundary(
      child: Text(
        isNegative
            ? '$negativeLeader$timeString'
            : '$positiveLeader$timeString',
        style: isNegative ? negativeStyle : positiveStyle,
      ),
    );
  }
}
