import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/value_listenable_utils.dart';

class NumericalQuestion extends StatelessWidget {
  final Score question;
  const NumericalQuestion({Key? key, required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      height: 280,
      child: Text("Numerical Question @TODO"),
    );
  }
}

class CategoricalQuestion extends StatefulWidget {
  final Score question;
  final Function(ScoreAnswer answer) onAnswer;
  final ScoreError error;
  final ScoreAnswer answer;
  const CategoricalQuestion({
    Key? key,
    required this.question,
    required this.onAnswer,
    required this.error,
    required this.answer,
  }) : super(key: key);

  @override
  State<CategoricalQuestion> createState() => _CategoricalQuestionState();
}

class _CategoricalQuestionState extends State<CategoricalQuestion> {
  List<String> _options = [];

  @override
  void initState() {
    super.initState();
    _options = widget.question.questionInput.categorical!.options;
  }

  Widget getRadioButton(String option, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: option,
          groupValue: widget.answer.answer,
          onChanged: (String? value) {
            if (value != null) {
              setState(() {
                widget.onAnswer(ScoreAnswer(answer: value, id: widget.question.id));
              });
            }
          },
        ),
        Text(option, style: TextStyle(fontSize: Responsive.isMobile(context) ? 10 : 12)),
      ],
    );
  }

  Widget getRadioButtons(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      alignment: WrapAlignment.end,
      children: [
        ..._options.map((option) {
          return getRadioButton(option, context);
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.0, color: AppTheme.isDarkTheme ? Colors.white : Colors.black),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center, // This ensures the label aligns with the top of the radio buttons
            children: [
              // Label is given non-flexible space.
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.4), // 40% of screen width. Adjust as required.
                child: Text(widget.question.label, style: const TextStyle(fontSize: 12)),
              ),

              // This spacing provides a small gap between the label and the radio buttons.
              const SizedBox(width: 8),

              // The radio buttons are given the remaining space.
              Expanded(
                child: getRadioButtons(context),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                widget.error.message,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuestionWidget extends StatelessWidget {
  final Score question;
  final ValueNotifier<List<ScoreError>> errorsNotifier;
  final ValueNotifier<ScoreAnswer> answerNotifier;
  final Function(ScoreAnswer answer) onAnswer;
  const QuestionWidget({
    Key? key,
    required this.question,
    required this.onAnswer,
    required this.errorsNotifier,
    required this.answerNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder2(
      first: errorsNotifier,
      second: answerNotifier,
      builder: (context, errors, answer, _) {
        var error = errors.firstWhere((e) => e.id.contains(question.id), orElse: () {
          return ScoreError(id: question.id, message: "");
        });

        if (question.questionInput.categorical != null) {
          return CategoricalQuestion(question: question, onAnswer: onAnswer, error: error, answer: answer);
        } else if (question.questionInput.numerical != null) {
          return NumericalQuestion(question: question);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
