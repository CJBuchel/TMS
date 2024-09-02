import 'package:flutter/material.dart';
import 'package:tms/generated/infra/fll_infra/category_question.dart';
import 'package:tms/widgets/buttons/category_button.dart';

class CategoricalQuestionWidget extends StatelessWidget {
  final CategoricalQuestion catQuestion;
  final Function(String)? onAnswer;

  final ValueNotifier<String?> answer = ValueNotifier(null);

  CategoricalQuestionWidget({
    Key? key,
    required this.catQuestion,
    required this.onAnswer,
  }) : super(key: key);

  Widget _categoryButton(String label) {
    // create container with min width of 100
    return Container(
      constraints: const BoxConstraints(minWidth: 80),
      child: IntrinsicWidth(
        child: ValueListenableBuilder(
          valueListenable: answer,
          builder: (context, value, child) {
            bool selected = false;
            if (value == label) {
              selected = true;
            } else if (value == null && catQuestion.defaultOption == label) {
              selected = true;
            }

            return CategoryButtonWidget(
              category: label,
              isSelected: selected,
              onSelected: (_) {
                answer.value = label;
                onAnswer?.call(label);
              },
            );
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
