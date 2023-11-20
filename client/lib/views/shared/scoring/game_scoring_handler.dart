import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/requests/game_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/network_image.dart';
import 'package:tms/views/shared/scoring/comments.dart';
import 'package:tms/views/shared/scoring/mission.dart';

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

  final ValueNotifier<bool> _currentlyValidatingNotifier = ValueNotifier<bool>(false);

  final List<ValueNotifier<ScoreAnswer>> _answerNotifiers = [];
  final ValueNotifier<List<ScoreError>> _errorsNotifier = ValueNotifier<List<ScoreError>>([]);

  // currently validating setters/getters
  get _getCurrentlyValidating => _currentlyValidatingNotifier.value;
  set _setCurrentlyValidating(bool val) {
    if (_currentlyValidatingNotifier.value != val) {
      _currentlyValidatingNotifier.value = val;
    }
  }

  Future<void> _validateScores() async {
    if (!_getCurrentlyValidating) {
      _setCurrentlyValidating = true;
      await getValidateQuestionsRequest(_getAnswers).then((res) {
        if (res.item1 == HttpStatus.ok) {
          _setErrors = res.item2.item2;
          widget.onScore?.call(res.item2.item1);
          widget.onErrors?.call(_getErrors);
        }
      });
      _setCurrentlyValidating = false;
    }
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
        if (_answerNotifiers[idx].value != answer) {
          _answerNotifiers[idx].value = answer;
        }
      } else {
        _answerNotifiers.add(ValueNotifier<ScoreAnswer>(answer));
      }
    }
    _validateScores();
    widget.onAnswers?.call(_getAnswers);
  }

  set _setAnswer(ScoreAnswer answer) {
    var idx = _answerNotifiers.indexWhere((a) => a.value.id == answer.id);
    if (idx != -1) {
      if (_answerNotifiers[idx].value != answer) {
        _answerNotifiers[idx].value = answer;
      }
    } else {
      _answerNotifiers.add(ValueNotifier<ScoreAnswer>(answer));
    }
    widget.onAnswers?.call(_getAnswers);
    _validateScores();
  }

  void _setDefault() async {
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

  List<Widget> _getMissions(Game game) {
    // wait for 2 seconds
    return game.missions.map((mission) {
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
    }).toList();
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
        ..._getMissions(widget.game),
        _scoringComments(),
      ],
    );
  }
}
