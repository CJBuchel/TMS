import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/clocks/match_ttl_clock.dart';

class MatchesInfo extends StatelessWidget {
  final ValueNotifier<List<GameMatch>> matches;
  final double? fontSize;

  const MatchesInfo({
    Key? key,
    required this.matches,
    required this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: matches,
      builder: (context, m, child) {
        int completedMatches = 0;
        for (GameMatch match in m) {
          if (match.complete) {
            completedMatches++;
          }
        }

        return Column(
          children: [
            // matches completed
            Expanded(
              flex: 1,
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Matches: $completedMatches/${m.length}",
                    style: TextStyle(fontSize: fontSize),
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Match TTL: ",
                    style: TextStyle(fontSize: fontSize),
                  ),
                  MatchTTLClock(matches: m, live: true, fontSize: fontSize, showOnlyClock: true),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
