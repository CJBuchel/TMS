import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:tms/constants.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/network/http.dart';
import 'package:tms/network/network.dart';
import 'package:tms/network/security.dart';
import 'package:tms/network/ws.dart';
import 'package:tms/requests/game_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/network_image.dart';
import 'package:tms/views/shared/scoring/comments.dart';
import 'package:tms/views/shared/scoring/mission.dart';

class GameScoring extends StatefulWidget {
  // initial values
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

  // value notifiers
  final ValueNotifier<bool>? setDefaultAnswers;

  const GameScoring({
    Key? key,
    this.initialAnswers,
    this.initialPublicComment,
    this.initialPrivateComment,
    this.onScore,
    this.onAnswers,
    this.onErrors,
    this.onPublicCommentChange,
    this.onPrivateCommentChange,
    this.onDefaultAnswers,
    this.setDefaultAnswers,
  }) : super(key: key);

  @override
  State<GameScoring> createState() => _GameScoringState();
}

class _GameScoringState extends State<GameScoring> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  Game _game = LocalDatabaseMixin.gameDefault();
  List<ScoreError> _errors = [];
  final List<ScoreAnswer> _answers = [];
  final TextEditingController _publicCommentController = TextEditingController();
  final TextEditingController _privateCommentController = TextEditingController();

  set _setGame(Game g) {
    if (mounted) {
      setState(() {
        _game = g;
      });

      if (widget.initialAnswers != null) {
        _setAnswers = widget.initialAnswers!;
      } else {
        _setDefault();
      }
    }
  }

  void _setDefault() {
    List<ScoreAnswer> answers = [];
    for (var q in _game.questions) {
      if (q.defaultValue.text != null) {
        answers.add(
          ScoreAnswer(
            id: q.id,
            answer: q.defaultValue.text!,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _answers.clear();
        _answers.addAll(answers);
      });
    }

    _validateScores();
    widget.onDefaultAnswers?.call();
  }

  void _validateScores() {
    getValidateQuestionsRequest(_answers).then((res) {
      if (res.item1 == HttpStatus.ok) {
        if (mounted) {
          setState(() {
            _errors = res.item2.item2;
            widget.onScore?.call(res.item2.item1);
            widget.onErrors?.call(_errors);
          });
        }
      }
    });
  }

  set _setAnswer(ScoreAnswer answer) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        var idx = _answers.indexWhere((a) => a.id == answer.id);
        if (idx != -1) {
          setState(() {
            _answers[idx] = answer;
          });
        } else {
          setState(() {
            _answers.add(answer);
          });
        }

        widget.onAnswers?.call(_answers);
        _validateScores();
      }
    });
  }

  set _setAnswers(List<ScoreAnswer> answers) {
    List<ScoreAnswer> updatedAnswers = [];
    for (var q in _game.questions) {
      if (q.defaultValue.text != null) {
        updatedAnswers.add(
          ScoreAnswer(
            id: q.id,
            answer: q.defaultValue.text!,
          ),
        );
      }
    }

    for (var answer in answers) {
      var idx = updatedAnswers.indexWhere((a) => a.id == answer.id);
      if (idx != -1) {
        updatedAnswers[idx] = answer;
      }
    }

    if (mounted) {
      setState(() {
        _answers.clear();
        _answers.addAll(updatedAnswers);
      });

      widget.onAnswers?.call(_answers);
      _validateScores();
    }
  }

  @override
  void initState() {
    super.initState();
    onGameEventUpdate((g) => _setGame = g);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!await Network.isConnected()) {
        getGame().then((g) => _setGame = g);
      }
    });

    NetworkHttp.httpState.addListener(_validateScores);
    NetworkWebSocket.wsState.addListener(_validateScores);
    NetworkSecurity.securityState.addListener(_validateScores);

    if (widget.initialPublicComment != null) {
      _publicCommentController.text = widget.initialPublicComment!;
    }

    if (widget.initialPrivateComment != null) {
      _privateCommentController.text = widget.initialPrivateComment!;
    }

    if (widget.setDefaultAnswers != null) {
      widget.setDefaultAnswers!.addListener(_setDefault);
    }
  }

  @override
  void dispose() {
    NetworkHttp.httpState.removeListener(_validateScores);
    NetworkWebSocket.wsState.removeListener(_validateScores);
    NetworkSecurity.securityState.removeListener(_validateScores);

    if (widget.setDefaultAnswers != null) {
      widget.setDefaultAnswers!.removeListener(_setDefault);
    }
    super.dispose();
  }

  List<Widget> _getMissions() {
    return _game.missions.map((mission) {
      return MissionWidget(
        color: (AppTheme.isDarkTheme ? const Color.fromARGB(255, 69, 80, 100) : Colors.white),
        mission: mission,
        errors: _errors,
        answers: _answers,
        image: NetworkImageWidget(
          src: mission.image ?? "",
          width: 160,
          height: 90,
          borderRadius: 10,
          defaultImage: const AssetImage('assets/images/FIRST_LOGO.png'),
        ),
        scores: _game.questions.where((q) {
          return q.id.startsWith(mission.prefix);
        }).toList(),
        onAnswers: (answers) {
          for (var answer in answers) {
            _setAnswer = answer;
          }
        },
      );
    }).toList();
  }

  Widget _scoringComments() {
    return ScoringComments(
      color: (AppTheme.isDarkTheme ? const Color.fromARGB(255, 69, 80, 100) : Colors.white),
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
        ..._getMissions(),
        _scoringComments(),
      ],
    );
  }
}
