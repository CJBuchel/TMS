import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/fll_infra/question.dart';
import 'package:tms/providers/game_scoring_provider.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/blueprint_scoring/question/categorical_question.dart';

class QuestionWidget extends StatelessWidget {
  final GlobalKey key;
  final Question question;
  final Function(String) onAnswer;

  const QuestionWidget({
    required this.key,
    required this.question,
    required this.onAnswer,
  }) : super(key: key);

  Widget _questionInput(BuildContext context, String? answer) {
    return question.input.when(
      categorical: (input) {
        return CategoricalQuestionWidget(
          catQuestion: input,
          answer: answer ?? input.defaultOption,
          onAnswer: onAnswer,
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
      child: Selector<GameScoringProvider, ({String? selectedAnswer, String? errorMessage})>(
        selector: (context, provider) {
          return (
            selectedAnswer: provider.getAnswer(question.id),
            errorMessage: provider.getValidationErrorMessage(question.id),
          );
        },
        builder: (context, questionData, child) {
          return Column(
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
                    child: _questionInput(context, questionData.selectedAnswer),
                  ),
                ],
              ),

              // validation error (@TODO)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      questionData.errorMessage ?? '',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
