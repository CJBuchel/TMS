import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/fll_infra/question.dart';
import 'package:tms/providers/game_scoring_provider.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/blueprint_scoring/question/categorical_question.dart';

class QuestionWidget extends StatelessWidget {
  final Question question;

  const QuestionWidget({
    Key? key,
    required this.question,
  }) : super(key: key);

  Widget _questionInput(BuildContext context) {
    return question.input.when(
      categorical: (input) {
        return CategoricalQuestionWidget(
          catQuestion: input,
          onAnswer: (a) => Provider.of<GameScoringProvider>(context, listen: false).onAnswer(
            QuestionAnswer(questionId: question.id, answer: a),
          ),
          // onAnswer: (a) => {},
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
              Expanded(
                child: Text(
                  question.label,
                  style: const TextStyle(fontSize: 12),
                ),
              ),

              // spacer
              const SizedBox(width: 8),

              Expanded(
                child: _questionInput(context),
              ),
            ],
          ),

          // validation error (@TODO)
          Selector<GameScoringProvider, String>(
            selector: (context, provider) => provider.getValidationErrorMessage(question.id),
            builder: (context, errorMessage, child) {
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
