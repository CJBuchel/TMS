import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/providers/shared_ticker_provider.dart';

String _secondsToTimeString(int totalSeconds) {
  int absSeconds = totalSeconds.abs();
  int hours = absSeconds ~/ 3600;
  int minutes = (absSeconds % 3600) ~/ 60;
  int seconds = absSeconds % 60;

  if (hours == 0 && minutes == 0) {
    return '$seconds';
  } else if (hours == 0) {
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  } else {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class TimeUntil extends ConsumerWidget {
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

  int _calculateDifference(DateTime now) {
    if (timeOfDayOnly) {
      final targetSeconds = time.hour * 3600 + time.minute * 60 + time.second;
      final nowSeconds = now.hour * 3600 + now.minute * 60 + now.second;
      return targetSeconds - nowSeconds;
    } else {
      return time.difference(now).inSeconds;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the shared ticker - all widgets update together
    final tickerState = ref.watch(
      sharedTickerProvider(const Duration(seconds: 1)),
    );
    final now = tickerState.value ?? DateTime.now();
    final difference = _calculateDifference(now);
    final timeString = _secondsToTimeString(difference);
    final isNegative = difference < 0;

    return Text(
      isNegative ? '$negativeLeader$timeString' : '$positiveLeader$timeString',
      style: isNegative ? negativeStyle : positiveStyle,
    );
  }
}
