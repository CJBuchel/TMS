import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/judge_advisor/event_information/judging_info.dart';
import 'package:tms/views/judge_advisor/event_information/matches_info.dart';

class EventInformation extends StatelessWidget {
  final ValueNotifier<List<GameMatch>> matches;
  final ValueNotifier<List<JudgingSession>> sessions;

  const EventInformation({
    Key? key,
    required this.matches,
    required this.sessions,
  }) : super(key: key);

  Widget _container({Widget? child, Color color = Colors.transparent}) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color,
          width: 2,
        ),
        gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [
          color,
          color,
          Colors.transparent,
          Colors.transparent,
          color,
          color,
        ], stops: const [
          0.0,
          0.05,
          0.05,
          0.95,
          0.95,
          1.0,
        ]),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = Responsive.isDesktop(context) ? 40 : 30;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // match info
            SizedBox(
              height: constraints.maxHeight * 0.5,
              child: _container(
                color: Colors.purple,
                child: MatchesInfo(
                  matches: matches,
                  fontSize: fontSize,
                ),
              ),
            ),

            // judge info
            SizedBox(
              height: constraints.maxHeight * 0.5,
              child: _container(
                color: Colors.blue,
                child: JudgingInfo(
                  sessions: sessions,
                  fontSize: fontSize,
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
