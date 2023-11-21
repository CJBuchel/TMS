import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/game_local_db.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/scoring/game_scoring_handler.dart';

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
  final ValueNotifier<bool> setDefaultAnswers;

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
    required this.setDefaultAnswers,
  }) : super(key: key);

  @override
  State<GameScoring> createState() => _GameScoringState();
}

class _GameScoringState extends State<GameScoring> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  final ValueNotifier<Game> _gameNotifier = ValueNotifier<Game>(GameLocalDB.singleDefault());

  void _setGame(Game g) async {
    if (!listEquals(_gameNotifier.value.missions, g.missions)) {
      _gameNotifier.value = g;
    }
  }

  @override
  void initState() {
    super.initState();
    // initial get game
    onGameUpdate((g) => _setGame(g));
  }

  Widget _getGameHandler() {
    return ValueListenableBuilder(
      valueListenable: _gameNotifier,
      builder: (context, game, _) {
        if (game.missions.isEmpty) {
          return const SizedBox.shrink();
        } else {
          return GameScoringHandler(
            // initials
            game: game,
            initialAnswers: widget.initialAnswers,
            initialPublicComment: widget.initialPublicComment,
            initialPrivateComment: widget.initialPrivateComment,

            // callbacks
            onScore: widget.onScore,
            onAnswers: widget.onAnswers,
            onErrors: widget.onErrors,
            onPublicCommentChange: widget.onPublicCommentChange,
            onPrivateCommentChange: widget.onPrivateCommentChange,
            onDefaultAnswers: widget.onDefaultAnswers,

            // notifiers
            setDefaultAnswers: widget.setDefaultAnswers,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getGame(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else {
          return _getGameHandler();
        }
      },
    );
  }
}
