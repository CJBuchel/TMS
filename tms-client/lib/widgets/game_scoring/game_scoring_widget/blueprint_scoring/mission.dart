import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/generated/infra/fll_infra/mission.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/blueprint_scoring/mission_image.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/blueprint_scoring/question/question.dart';

class MissionWidget extends StatelessWidget {
  final Mission mission;
  final List<QuestionWidget> missionQuestions;
  final String season;

  const MissionWidget({
    Key? key,
    required this.mission,
    required this.missionQuestions,
    required this.season,
  }) : super(key: key);

  List<Widget> getMissionHeader(BuildContext context) {
    double width = 160;
    double height = 90;
    double fontSize = 10;

    if (ResponsiveBreakpoints.of(context).isDesktop) {
      width = 240;
      height = 140;
      fontSize = 16;
    } else if (ResponsiveBreakpoints.of(context).isTablet) {
      width = 200;
      height = 120;
      fontSize = 12;
    } else {
      width = 160;
      height = 90;
    }

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
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: MissionImage(
          mission: mission,
          season: season,
          width: width,
          height: height,
          borderRadius: 10,
        ),
      ),
    ];
  }

  Color getMissionColor(BuildContext context) {
    Color darkColor = lighten(Theme.of(context).cardColor, 0.05);
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
          ...missionQuestions,

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
