import 'package:flutter/material.dart';
import 'package:tms/generated/infra/fll_infra/question.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/question/categorical_question.dart';

class QuestionWidget extends StatelessWidget {
  final Question question;
  final Function(QuestionAnswer)? onAnswer;

  const QuestionWidget({
    Key? key,
    required this.question,
    this.onAnswer,
  }) : super(key: key);

  Widget _questionInput() {
    return question.input.when(
      categorical: (input) {
        return CategoricalQuestionWidget(
          catQuestion: input,
          onAnswer: (a) => onAnswer?.call(QuestionAnswer(questionId: question.id, answer: a)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  question.label,
                  style: const TextStyle(fontSize: 12),
                ),
              ),

              // spacer
              const SizedBox(width: 8),

              Expanded(
                child: _questionInput(),
              ),
            ],
          ),

          // validation error (@TODO)
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Validation Error @TODO",
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
