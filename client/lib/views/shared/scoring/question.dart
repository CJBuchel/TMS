import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';

class NumericalQuestion extends StatelessWidget {
  final Score score;
  const NumericalQuestion({Key? key, required this.score}) : super(key: key);

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
  final Score score;
  final Function(ScoreAnswer answer) onAnswer;
  final ScoreError error;
  final ScoreAnswer answer;
  const CategoricalQuestion({
    Key? key,
    required this.score,
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
    _options = widget.score.questionInput.categorical!.options;
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
                widget.onAnswer(ScoreAnswer(answer: value, id: widget.score.id));
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
                child: Text(widget.score.label, style: const TextStyle(fontSize: 12)),
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
  final Score score;
  final List<ScoreError> errors;
  final Function(ScoreAnswer answer) onAnswer;
  final List<ScoreAnswer> answers;
  const QuestionWidget({
    Key? key,
    required this.score,
    required this.onAnswer,
    required this.errors,
    required this.answers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var error = ScoreError(id: "", message: "");
    var scoreAnswer = ScoreAnswer(answer: "", id: "");
    for (var e in errors) {
      if (e.id.contains(score.id)) {
        error = e;
      }
    }
    for (var a in answers) {
      if (a.id.contains(score.id)) {
        scoreAnswer = a;
      }
    }
    if (score.questionInput.categorical != null) {
      return CategoricalQuestion(score: score, onAnswer: onAnswer, error: error, answer: scoreAnswer);
    } else if (score.questionInput.numerical != null) {
      return NumericalQuestion(score: score);
    } else {
      return const SizedBox.shrink();
    }
  }
}
