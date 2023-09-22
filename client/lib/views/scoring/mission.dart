import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/scoring/question.dart';
import 'package:tms/views/shared/network_image.dart';

class MissionWidget extends StatelessWidget {
  final Mission mission;
  final List<Score> scores;
  final List<ScoreError> errors;
  final Function(List<ScoreAnswer>) onAnswers;
  final List<ScoreAnswer> answers;
  final Color? color;
  final NetworkImageWidget? image;

  const MissionWidget({
    Key? key,
    required this.mission,
    required this.scores,
    required this.errors,
    required this.onAnswers,
    required this.answers,
    required this.image,
    this.color,
  }) : super(key: key);

  Widget getMissionHeader(BuildContext context) {
    if (!Responsive.isMobile(context)) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: image,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              mission.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              mission.title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: image,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
        border: Border.all(
          color: AppTheme.isDarkTheme ? Colors.black : Colors.black,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getMissionHeader(context),
          ...scores.map(
            (score) => QuestionWidget(
              score: score,
              onAnswer: (answer) {
                onAnswers([answer]);
              },
              errors: errors,
              answers: answers,
            ),
          ),
        ],
      ),
    );
  }
}
