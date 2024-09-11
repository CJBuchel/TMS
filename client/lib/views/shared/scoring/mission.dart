import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/network_image.dart';
import 'package:tms/views/shared/scoring/question.dart';

class MissionWidget extends StatelessWidget {
  final Mission mission;
  final List<Score> questions;

  final ValueNotifier<List<ScoreError>> errorsNotifier;
  final List<ValueNotifier<ScoreAnswer>> answerNotifiers;
  final Function(List<ScoreAnswer>) onAnswers;
  final Color? color;
  final NetworkImageWidget? image;

  const MissionWidget({
    Key? key,
    required this.mission,
    required this.questions,
    required this.errorsNotifier,
    required this.answerNotifiers,
    required this.onAnswers,
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
          ...questions.map((question) {
            var answerN = answerNotifiers.firstWhere((a) => a.value.id == question.id, orElse: () {
              return ValueNotifier(ScoreAnswer(id: question.id, answer: ""));
            });

            return QuestionWidget(
              question: question,
              onAnswer: (answer) {
                onAnswers([answer]);
              },
              errorsNotifier: errorsNotifier,
              answerNotifier: answerN,
            );
          }),
        ],
      ),
    );
  }
}
