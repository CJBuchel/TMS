import 'package:flutter/material.dart';
import 'package:tms/generated/infra/fll_infra/mission.dart';
import 'package:tms/generated/infra/fll_infra/question.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/mission_image.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/question/question.dart';

class MissionWidget extends StatelessWidget {
  final Mission mission;
  final List<Question> missionQuestions;
  final String season;

  const MissionWidget({
    Key? key,
    required this.mission,
    required this.missionQuestions,
    required this.season,
  }) : super(key: key);

  List<Widget> getMissionHeader(BuildContext context) {
    return [
      Container(
        decoration: const BoxDecoration(
          // color: Color(0xFF4C779F),
          color: Colors.green,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
          child: Text(
            mission.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: MissionImage(
          mission: mission,
          season: season,
          width: 160,
          height: 90,
          borderRadius: 10,
        ),
      ),
    ];
  }

  Color getMissionColor(BuildContext context) {
    // Color darkColor = const Color(0xFF100023);
    // get number out of the mission.id
    Color darkColor = lighten(Theme.of(context).cardColor, 0.05);
    // Color darkColor = lighten(Theme.of(context).cardColor, 0.05);
    Color lightColor = Theme.of(context).cardColor;
    return Theme.of(context).brightness == Brightness.dark ? darkColor : lightColor;
  }

  Color? getDecorationColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? Colors.purple : Colors.purple[300];
  }

  @override
  Widget build(BuildContext context) {
    // array of the questions in a column
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.fromLTRB(40, 10, 40, 10),
      decoration: BoxDecoration(
        color: getMissionColor(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
        border: Border.all(
          width: 1,
          color: Colors.black,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...getMissionHeader(context),
          ...missionQuestions.map((q) {
            return QuestionWidget(
              question: q,
              onAnswer: (a) {
                TmsLogger().i('Answered question: ${a.questionId} with answer: ${a.answer}');
              },
            );
          }).toList(),

          // colored bottom segment (just to make it look nice)
          Container(
            margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            decoration: BoxDecoration(
              color: getDecorationColor(context),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
              ),
            ),
            height: 20,
          ),
        ],
      ),
    );
  }
}
