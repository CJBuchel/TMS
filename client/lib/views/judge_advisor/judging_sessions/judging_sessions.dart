import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/parse_util.dart';
import 'package:tms/views/judge_advisor/judging_sessions/pods_table.dart';

class JudgingSessions extends StatelessWidget {
  final ValueNotifier<List<Team>> teams;
  final ValueNotifier<List<JudgingSession>> judgingSessions;

  const JudgingSessions({
    Key? key,
    required this.teams,
    required this.judgingSessions,
  }) : super(key: key);

  AccordionSection _section(BuildContext context, int index, {bool focused = false}) {
    bool isInSession = DateTime.now().isAfter(parseStringTimeToDateTime(judgingSessions.value[index].startTime) ?? DateTime.now());
    Color? defaultColor = Theme.of(context).colorScheme.secondary.withOpacity(0.1);
    Color? headerColor = judgingSessions.value[index].complete ? Colors.green : (isInSession ? Colors.red : defaultColor);

    // section
    return AccordionSection(
      headerBackgroundColor: headerColor,
      contentBackgroundColor: Theme.of(context).cardColor,
      isOpen: focused, // start open if it's focused
      header: ValueListenableBuilder(
        valueListenable: judgingSessions,
        builder: (context, sessions, child) {
          int submitted = sessions[index].judgingPods.where((e) => e.scoreSubmitted).length;

          return SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  sessions[index].sessionNumber,
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  sessions[index].startTime,
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  "Submissions: $submitted/${sessions[index].judgingPods.length}",
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          );
        },
      ),
      content: ValueListenableBuilder(
        valueListenable: judgingSessions,
        builder: (context, s, child) {
          return ValueListenableBuilder(
            valueListenable: teams,
            builder: (context, t, child) {
              return PodsTable(teams: t, session: s[index]);
            },
          );
        },
      ),
    );
  }

  List<AccordionSection> _sections(BuildContext context) {
    return List<AccordionSection>.generate(judgingSessions.value.length, (index) {
      int focusedIndex = 0;

      // find the first session that is not complete
      for (int i = 0; i < judgingSessions.value.length; i++) {
        if (!judgingSessions.value[i].complete) {
          focusedIndex = i;
          break;
        }
      }

      return _section(context, index, focused: (focusedIndex == index));
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      return SizedBox(
        height: constrains.maxHeight,
        width: constrains.maxWidth,
        child: Column(
          children: [
            const SizedBox(
              height: 50,
              child: Center(
                child: Text(
                  "Judging Sessions",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Accordion(
                  maxOpenSections: 1,
                  children: _sections(context),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
