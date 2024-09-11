import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/clocks/match_ttl_clock.dart';

class MatchTimers extends StatelessWidget {
  final List<GameMatch> matches;
  final double? fontSize;

  const MatchTimers({
    Key? key,
    required this.matches,
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
                "Games: ",
                style: TextStyle(fontSize: fontSize),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: _cell(
            child: Center(
              child: MatchTTLClock(
                matches: matches,
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
              child: MatchTTLClock(
                matches: matches,
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
