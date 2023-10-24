import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/clocks/judging_ttl_clock.dart';

class JudgingInfo extends StatelessWidget {
  final ValueNotifier<List<JudgingSession>> sessions;
  final double? fontSize;

  const JudgingInfo({
    Key? key,
    required this.sessions,
    required this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: sessions,
      builder: (context, s, child) {
        int completedSessions = 0;
        for (JudgingSession session in s) {
          if (session.complete) {
            completedSessions++;
          }
        }

        return Column(
          children: [
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
                    "Sessions: $completedSessions/${s.length}",
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
                    "Judging TTL: ",
                    style: TextStyle(fontSize: fontSize),
                  ),
                  JudgingTTLClock(sessions: s, live: true, fontSize: fontSize, showOnlyClock: true),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
