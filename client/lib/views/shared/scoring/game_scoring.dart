import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/game_local_db.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/requests/game_requests.dart';
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
  }) : super(key: key);

  @override
  State<GameScoring> createState() => GameScoringState();
}

class GameScoringState extends State<GameScoring> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  final ValueNotifier<Game> _gameNotifier = ValueNotifier<Game>(GameLocalDB.singleDefault());
  final GlobalKey<GameScoringHandlerState> _gameScoringHandlerKey = GlobalKey();

  GlobalKey<GameScoringHandlerState> get getGameScoringHandlerKey => _gameScoringHandlerKey;

  void _setGame(Game g) async {
    if (!listEquals(_gameNotifier.value.missions, g.missions)) {
      _gameNotifier.value = g;
    }
  }

  void fetchGame() async {
    getGameRequest().then((g) {
      if (g.item1 == HttpStatus.ok && g.item2 != null) {
        _setGame(g.item2!);
      } else {
        Logger().w("Game fetch failed");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // initial get game
    onGameUpdate((g) => _setGame(g));
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchGame());
  }

  Widget _getGameHandler() {
    return ValueListenableBuilder(
      valueListenable: _gameNotifier,
      builder: (context, game, _) {
        if (game.missions.isEmpty) {
          return const SizedBox.shrink();
        } else {
          return GameScoringHandler(
            // key
            key: _gameScoringHandlerKey,
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
