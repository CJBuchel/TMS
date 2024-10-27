import 'package:flutter/material.dart';
import 'package:tms/generated/infra/fll_infra/category_question.dart';
import 'package:tms/widgets/buttons/category_button.dart';

class CategoricalQuestionWidget extends StatelessWidget {
  final CategoricalQuestion catQuestion;
  final Function(String)? onAnswer;
  final String answer;

  const CategoricalQuestionWidget({
    Key? key,
    required this.catQuestion,
    required this.onAnswer,
    required this.answer,
  }) : super(key: key);

  Widget _categoryButton(String label) {
    // create container with min width of 100
    return Container(
      constraints: const BoxConstraints(minWidth: 80),
      child: IntrinsicWidth(
        child: CategoryButtonWidget(
          category: label,
          isSelected: answer == label,
          onSelected: (_) {
            onAnswer?.call(label);
          },
        ),
      ),
    );
  }

  Widget _wrappedCategoryButtons() {
    return Wrap(
      spacing: 2.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.end,
      children: [
        ...catQuestion.options.map((option) {
          return _categoryButton(option.label);
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _wrappedCategoryButtons();
  }
}
