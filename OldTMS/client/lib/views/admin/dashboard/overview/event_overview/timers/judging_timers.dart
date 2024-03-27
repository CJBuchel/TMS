import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/clocks/judging_ttl_clock.dart';

class JudgingTimers extends StatelessWidget {
  final List<JudgingSession> judgingSessions;
  final double? fontSize;

  const JudgingTimers({
    Key? key,
    required this.judgingSessions,
    this.fontSize,
  }) : super(key: key);

  Widget _cell({Widget? child}) {
    return Center(child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 1,
          child: _cell(
            child: Center(
              child: Text(
                "Judging: ",
                style: TextStyle(fontSize: fontSize),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: _cell(
            child: Center(
              child: JudgingTTLClock(
                sessions: judgingSessions,
                timerColor: AppTheme.isDarkTheme ? Colors.white : Colors.black,
                showOnlyClock: true,
                live: false,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: _cell(
            child: Center(
              child: JudgingTTLClock(
                sessions: judgingSessions,
                showOnlyClock: true,
                live: true,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
