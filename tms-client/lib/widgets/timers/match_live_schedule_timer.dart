import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/utils/sorter_util.dart';
import 'package:tms/utils/tms_time_utils.dart';

class _MatchLiveScheduleTimer extends StatefulWidget {
  final TextStyle? positiveStyle;
  final TextStyle? negativeStyle;
  final List<GameMatch> matches;

  const _MatchLiveScheduleTimer({
    Key? key,
    this.positiveStyle,
    this.negativeStyle,
    required this.matches,
  }) : super(key: key);

  @override
  State<_MatchLiveScheduleTimer> createState() => _MatchLiveScheduleTimerState();
}

class _MatchLiveScheduleTimerState extends State<_MatchLiveScheduleTimer> {
  Timer? _timer;
  ValueNotifier<int> _difference = ValueNotifier<int>(0);

  Future<int> getTimeDifference() async {
    // current time
    List<GameMatch> matches = sortMatchesByTime(widget.matches);

    // find the first match that is not completed
    int diff = 0;
    for (GameMatch match in matches) {
      if (!match.completed) {
        diff = tmsDateTimeGetDifferenceFromNow(match.startTime);
        break;
      }
    }

    return diff;
  }

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      getTimeDifference().then((value) {
        _difference.value = value;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _difference,
      builder: (context, diff, child) {
        String stringTime = secondsToTimeString(diff);
        return Text(
          diff < 0 ? "-$stringTime" : "+$stringTime",
          style: diff < 0 ? widget.negativeStyle : widget.positiveStyle,
        );
      },
    );
  }
}

class MatchLiveScheduleTimer extends StatelessWidget {
  final TextStyle? positiveStyle;
  final TextStyle? negativeStyle;

  const MatchLiveScheduleTimer({
    Key? key,
    this.positiveStyle,
    this.negativeStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<GameMatchProvider, List<GameMatch>>(
      selector: (context, provider) => provider.matches,
      shouldRebuild: (previous, next) => !listEquals(previous, next),
      builder: (context, matches, child) {
        return RepaintBoundary(
          child: _MatchLiveScheduleTimer(
            positiveStyle: positiveStyle,
            negativeStyle: negativeStyle,
            matches: matches,
          ),
        );
      },
    );
  }
}
