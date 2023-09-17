import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';

class NumericalQuestion extends StatelessWidget {
  final Score score;
  const NumericalQuestion({Key? key, required this.score}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      height: 280,
      child: Text("Numerical Question"),
    );
  }
}

class CategoricalQuestion extends StatelessWidget {
  final Score score;
  const CategoricalQuestion({Key? key, required this.score}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(score.label),
      subtitle: Text(score.labelShort),
      trailing: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          for (var option in score.questionInput.categorical?.options ?? [])
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(option),
            ),
        ],
      ),
    );
  }
}

class QuestionWidget extends StatelessWidget {
  final Score score;
  const QuestionWidget({Key? key, required this.score}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NumericalQuestion(score: score);
    // if (score.questionInput.categorical != null) {
    //   return CategoricalQuestion(score: score);
    // } else if (score.questionInput.numerical != null) {
    // } else {
    //   return const SizedBox.shrink();
    // }
  }
}
