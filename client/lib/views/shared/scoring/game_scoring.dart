import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:tms/constants.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/game_local_db.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/network/network.dart';
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
  final Function()? onLoaded;

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
    this.onLoaded,
  }) : super(key: key);

  @override
  State<GameScoring> createState() => _GameScoringState();
}

class _GameScoringState extends State<GameScoring> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  Game _game = GameLocalDB.singleDefault();
  List<ScoreError> _errors = [];
  final List<ScoreAnswer> _answers = [];
  final TextEditingController _publicCommentController = TextEditingController();
  final TextEditingController _privateCommentController = TextEditingController();

  set _setGame(Game g) {
    if (mounted) {
      // check if the game is the same
      bool same = false;
      if (listEquals(g.missions, _game.missions)) {
        same = true;
      }

      if (listEquals(g.questions, _game.questions)) {
        same = true;
      }

      if (!same) {
        setState(() {
          _game = g;
          _setInitialAnswers();
        });
      }
    }
  }

  Future<void> _validateScores() async {
    await getValidateQuestionsRequest(_answers).then((res) {
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

  Future<void> _setDefault() async {
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

    await _validateScores();
    widget.onDefaultAnswers?.call();
  }

  Future<void> _setInitialAnswers() async {
    if (widget.initialAnswers != null) {
      _setAnswers = widget.initialAnswers!;
      await _validateScores();
    } else {
      await _setDefault();
    }

    widget.onAnswers?.call(_answers);
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

  Future<void> _getGame() async {
    _setGame = await getGame();
  }

  Future<void> _setData() async {
    await _getGame();
    if (_answers.isNotEmpty) {
      if (await Network.isConnected()) {
        await _validateScores();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // initial get game
    onGameUpdate((g) => _setGame = g);

    if (widget.initialPublicComment != null) {
      _publicCommentController.text = widget.initialPublicComment!;
    }

    if (widget.initialPrivateComment != null) {
      _privateCommentController.text = widget.initialPrivateComment!;
    }

    if (widget.setDefaultAnswers != null) {
      widget.setDefaultAnswers!.addListener(_setDefault);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setData();
    });
  }

  @override
  void dispose() {
    if (widget.setDefaultAnswers != null) {
      widget.setDefaultAnswers!.removeListener(_setDefault);
    }
    super.dispose();
  }

  Future<List<Widget>> _getMissions() async {
    // wait for 2 seconds
    await Future.delayed(const Duration(milliseconds: 200));
    return _game.missions.map((mission) {
      return MissionWidget(
        color: (AppTheme.isDarkTheme ? secondaryCardColor : Colors.white),
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
    return FutureBuilder<List<Widget>>(
      future: _getMissions(),
      builder: (context, snapshot) {
        if (snapshot.hasData && (snapshot.data?.isNotEmpty ?? false)) {
          widget.onLoaded?.call();
          return Column(
            children: [
              ...snapshot.data!,
              _scoringComments(),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
