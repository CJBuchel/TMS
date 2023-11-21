import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/requests/game_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/network_image.dart';
import 'package:tms/views/shared/scoring/comments.dart';
import 'package:tms/views/shared/scoring/mission.dart';
import 'package:tms/views/shared/scoring/validation_queue.dart';

class GameScoringHandler extends StatefulWidget {
  // initial values
  final Game game;
  final List<ScoreAnswer>? initialAnswers;
  final String? initialPublicComment;
  final String? initialPrivateComment;

  // function callbacks
  final Function(int)? onScore;
  final Function(List<ScoreAnswer>)? onAnswers;
  final Function(List<ScoreError>)? onErrors;
  final Function(String)? onPublicCommentChange;
  final Function(String)? onPrivateCommentChange;
  final Function()? onDefaultAnswers;

  // notifiers
  final ValueNotifier<bool>? setDefaultAnswers;
  const GameScoringHandler({
    Key? key,
    // initials
    required this.game,
    required this.initialAnswers,
    required this.initialPublicComment,
    required this.initialPrivateComment,

    // callbacks
    required this.onScore,
    required this.onAnswers,
    required this.onErrors,
    required this.onPublicCommentChange,
    required this.onPrivateCommentChange,
    required this.onDefaultAnswers,

    // notifiers
    required this.setDefaultAnswers,
  }) : super(key: key);

  @override
  State<GameScoringHandler> createState() => _GameScoringHandlerState();
}

class _GameScoringHandlerState extends State<GameScoringHandler> {
  final TextEditingController _publicCommentController = TextEditingController();
  final TextEditingController _privateCommentController = TextEditingController();

  final List<ValueNotifier<ScoreAnswer>> _answerNotifiers = [];
  final ValueNotifier<List<ScoreError>> _errorsNotifier = ValueNotifier<List<ScoreError>>([]);

  void _validateScores() {
    // check if any of the answers are empty
    for (ScoreAnswer answer in _getAnswers) {
      if (answer.answer.isEmpty) {
        return;
      }
    }

    ValidationQueue().addValidation(() async {
      // time it takes to validate
      var startTime = DateTime.now();
      await getValidateQuestionsRequest(_getAnswers).then((res) {
        if (res.item1 == HttpStatus.ok) {
          _setErrors = res.item2.item2;
          widget.onScore?.call(res.item2.item1);
          widget.onErrors?.call(_getErrors);
        }
      });
      var endTime = DateTime.now();
      if (endTime.difference(startTime).inMilliseconds > 500) {
        print("Validation took ${endTime.difference(startTime).inMilliseconds}ms");
      }
    });
  }

  // error setters/getters
  get _getErrors => _errorsNotifier.value;
  set _setErrors(List<ScoreError> errors) {
    if (!listEquals(_getErrors, errors)) {
      _errorsNotifier.value = errors;
    }
  }

  // answer setters/getters
  get _getAnswers => _answerNotifiers.map((e) => e.value).toList();
  set _setAnswers(List<ScoreAnswer> answers) {
    for (var answer in answers) {
      var idx = _answerNotifiers.indexWhere((a) => a.value.id == answer.id);
      if (idx != -1) {
        if (_answerNotifiers[idx].value != answer && mounted) {
          _answerNotifiers[idx].value = answer;
        }
      } else {
        _answerNotifiers.add(ValueNotifier<ScoreAnswer>(answer));
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateScores();
      widget.onAnswers?.call(_getAnswers);
    });
  }

  set _setAnswer(ScoreAnswer answer) {
    var idx = _answerNotifiers.indexWhere((a) => a.value.id == answer.id);
    if (idx != -1) {
      if (_answerNotifiers[idx].value != answer && mounted) {
        _answerNotifiers[idx].value = answer;
      }
    } else {
      _answerNotifiers.add(ValueNotifier<ScoreAnswer>(answer));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateScores();
      widget.onAnswers?.call(_getAnswers);
    });
  }

  void _setDefault() {
    List<ScoreAnswer> answers = [];
    for (var q in widget.game.questions) {
      answers.add(ScoreAnswer(
        id: q.id,
        answer: q.defaultValue.text ?? "",
      ));
    }

    _setAnswers = answers;
    widget.onDefaultAnswers?.call();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialPublicComment != null) {
      _publicCommentController.text = widget.initialPublicComment!;
    }

    if (widget.initialPrivateComment != null) {
      _privateCommentController.text = widget.initialPrivateComment!;
    }

    if (widget.initialAnswers != null) {
      _setAnswers = widget.initialAnswers!;
    } else {
      _setDefault();
    }

    // check for default answers
    if (widget.setDefaultAnswers != null) {
      widget.setDefaultAnswers?.addListener(_setDefault);
    }
  }

  @override
  void dispose() {
    if (widget.setDefaultAnswers != null) {
      widget.setDefaultAnswers?.removeListener(_setDefault);
    }
    super.dispose();
  }

  Widget _getMissions(Game game) {
    // wait for 2 seconds
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: game.missions.length,
      itemBuilder: (context, index) {
        Mission mission = game.missions[index];
        return MissionWidget(
          color: (AppTheme.isDarkTheme ? secondaryCardColor : Colors.white),
          mission: mission,
          questions: game.questions.where((q) {
            return q.id.startsWith(mission.prefix);
          }).toList(),
          errorsNotifier: _errorsNotifier,
          answerNotifiers: _answerNotifiers,
          onAnswers: (answers) {
            for (var answer in answers) {
              _setAnswer = answer;
            }
          },
          image: NetworkImageWidget(
            src: mission.image ?? "",
            width: 160,
            height: 90,
            borderRadius: 10,
            defaultImage: const AssetImage('assets/images/FIRST_LOGO.png'),
          ),
        );
      },
    );
  }

  Widget _scoringComments() {
    return ScoringComments(
      color: (AppTheme.isDarkTheme ? secondaryCardColor : Colors.white),
      publicCommentController: _publicCommentController,
      privateCommentController: _privateCommentController,
      onPublicCommentChange: (pub) {
        widget.onPublicCommentChange?.call(pub);
      },
      onPrivateCommentChange: (priv) {
        widget.onPrivateCommentChange?.call(priv);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _getMissions(widget.game),
        _scoringComments(),
      ],
    );
  }
}
