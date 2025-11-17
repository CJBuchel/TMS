import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_score_sheet.dart';
import 'package:tms/generated/infra/fll_infra/fll_blueprint.dart';
import 'package:tms/generated/infra/fll_infra/fll_blueprint_map.dart';
import 'package:tms/generated/infra/fll_infra/mission.dart';
import 'package:tms/generated/infra/fll_infra/question.dart';
import 'package:tms/generated/infra/network_schemas/tournament_config_requests.dart';
import 'package:tms/providers/robot_game_providers/game_scoring_provider.dart';
import 'package:tms/providers/tournament_config_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/agnostic_scoring/agnostic_scoring.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/blueprint_scoring/mission.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/blueprint_scoring/private_comment.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/blueprint_scoring/question/question.dart';

class _BlueprintData {
  final BlueprintType type;
  final String season;
  final FllBlueprint blueprint;

  _BlueprintData(
      {required this.type, required this.season, required this.blueprint});
}

class _QuestionKeyData {
  final GlobalKey key = GlobalKey();
  final Question question;

  _QuestionKeyData({required this.question});
}

class GameScoringWidget extends StatelessWidget {
  final ScrollController? scrollController;
  final List<_QuestionKeyData> questionKeys = [];
  final GameScoreSheet? scoreSheet;

  GameScoringWidget({
    Key? key,
    required this.scrollController,
    this.scoreSheet,
  }) : super(key: key);

  void _initializeQuestionKeys(List<Question> questions) {
    questionKeys.clear();
    questionKeys.addAll(List.generate(questions.length,
        (index) => _QuestionKeyData(question: questions[index])));
  }

  void _scrollToNextQuestion(int currentIndex) {
    // If the scrollController is null or has no clients, return
    if (scrollController == null || !(scrollController?.hasClients ?? false))
      return;
    if (currentIndex + 1 < questionKeys.length) {
      final nextKey = questionKeys[currentIndex + 1];
      final nextContext = nextKey.key.currentContext;

      if (nextContext != null) {
        final RenderBox renderBox = nextContext.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(
          Offset.zero,
          ancestor: scrollController!.position.context.storageContext
              .findRenderObject() as RenderObject,
        );

        // Calculate the offset to center the next question
        final viewportHeight = scrollController!.position.viewportDimension;
        final targetOffset = position.dy +
            scrollController!.offset -
            (viewportHeight / 2) +
            (renderBox.size.height / 2);

        scrollController!.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        TmsLogger().w("Next question context is null, can't scroll to it");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [":tournament:config"],
      child: Selector<TournamentConfigProvider, _BlueprintData>(
        selector: (context, config) {
          final blueprint =
              FllBlueprintMap.getFllBlueprint(season: config.season);
          var type = config.blueprintType;

          if (scoreSheet != null) {
            type = scoreSheet!.isAgnostic
                ? BlueprintType.agnostic
                : BlueprintType.seasonal;
          }

          return _BlueprintData(
            type: type,
            season: config.season,
            blueprint: blueprint ?? FllBlueprint.default_(),
          );
        },
        builder: (context, data, child) {
          if (scoreSheet != null) {
            Provider.of<GameScoringProvider>(context, listen: false)
                .privateComment = scoreSheet!.privateComment;
          }

          if (data.type == BlueprintType.agnostic) {
            if (scoreSheet != null) {
              Provider.of<GameScoringProvider>(context, listen: false)
                  .rawScore = scoreSheet!.score;
            }
            return AgnosticScoringWidget(
              onScoreChanged: (score, comment) {
                Provider.of<GameScoringProvider>(context, listen: false).score =
                    score;
                Provider.of<GameScoringProvider>(context, listen: false)
                    .privateComment = comment;
              },
            );
          } else {
            _initializeQuestionKeys(data.blueprint.robotGameQuestions);
            if (scoreSheet != null) {
              Provider.of<GameScoringProvider>(context, listen: false).answers =
                  scoreSheet!.scoreSheetAnswers;
            }
            return CustomScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: data.blueprint.robotGameMissions.length,
                    (context, index) {
                      Mission mission = data.blueprint.robotGameMissions[index];
                      // List<Question> allQuestions = data.blueprint.robotGameQuestions;
                      List<_QuestionKeyData> missionQuestions = questionKeys
                          .where((q) => q.question.id.startsWith(mission.id))
                          .toList();

                      return MissionWidget(
                        mission: mission,
                        missionQuestions:
                            missionQuestions.map((questionKeyData) {
                          final key = questionKeyData.key;

                          final questionWidget = QuestionWidget(
                            key: key,
                            question: questionKeyData.question,
                            onAnswer: (a) async {
                              TmsLogger().d(
                                  "Answered question ${questionKeyData.question.id} with answer $a");
                              _scrollToNextQuestion(
                                  questionKeys.indexOf(questionKeyData));
                              Provider.of<GameScoringProvider>(context,
                                      listen: false)
                                  .onAnswer(
                                QuestionAnswer(
                                    questionId: questionKeyData.question.id,
                                    answer: a),
                              );
                            },
                          );
                          return questionWidget;
                        }).toList(),
                        season: data.season,
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: PrivateCommentWidget(
                    comment: Provider.of<GameScoringProvider>(context)
                        .privateComment,
                    onCommentChanged: (c) {
                      Provider.of<GameScoringProvider>(context, listen: false)
                          .privateComment = c;
                    },
                    isCommentNeeded: Provider.of<GameScoringProvider>(context)
                        .isCommentRequired,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
