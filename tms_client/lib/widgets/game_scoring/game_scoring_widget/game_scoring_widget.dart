import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_score_sheet.dart';
import 'package:tms/generated/infra/database_schemas/tournament_blueprint.dart';
import 'package:tms/generated/infra/fll_infra/mission.dart';
import 'package:tms/generated/infra/fll_infra/question.dart';
import 'package:tms/generated/infra/network_schemas/tournament_config_requests.dart';
import 'package:tms/providers/robot_game_providers/game_scoring_provider.dart';
import 'package:tms/providers/tournament_blueprint_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/agnostic_scoring/agnostic_scoring.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/blueprint_scoring/mission.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/blueprint_scoring/private_comment.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/blueprint_scoring/question/question.dart';

class _BlueprintData {
  final BlueprintType type;
  final TournamentBlueprint? blueprint;

  _BlueprintData({required this.type, required this.blueprint});
}

class GameScoringWidget extends StatelessWidget {
  final ScrollController? scrollController;
  final List<GlobalKey> questionKeys = [];

  final GameScoreSheet? scoreSheet;

  GameScoringWidget({
    Key? key,
    required this.scrollController,
    this.scoreSheet,
  }) : super(key: key);

  void _scrollToNextQuestion(int currentIndex) {
    // If the scrollController is null or has no clients, return
    if (scrollController == null || !(scrollController?.hasClients ?? false)) return;
    if (currentIndex + 1 < questionKeys.length) {
      final nextKey = questionKeys[currentIndex + 1];
      final nextContext = nextKey.currentContext;

      if (nextContext != null) {
        final RenderBox renderBox = nextContext.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(
          Offset.zero,
          ancestor: scrollController!.position.context.storageContext.findRenderObject() as RenderObject,
        );

        // Calculate the offset to center the next question
        final viewportHeight = scrollController!.position.viewportDimension;
        final targetOffset =
            position.dy + scrollController!.offset - (viewportHeight / 2) + (renderBox.size.height / 2);

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
      trees: [":tournament:blueprint", ":tournament:config"],
      child: Selector<TournamentBlueprintProvider, _BlueprintData>(
        selector: (context, bp) {
          if (scoreSheet != null) {
            // get blueprint type
            var type = scoreSheet!.isAgnostic ? BlueprintType.agnostic : BlueprintType.seasonal;
            return _BlueprintData(type: type, blueprint: bp.getBlueprint(scoreSheet!.blueprintTitle));
          } else {
            String blueprintTitle = bp.season;
            return _BlueprintData(type: bp.blueprintType, blueprint: bp.getBlueprint(blueprintTitle));
          }
        },
        builder: (context, data, child) {
          if (scoreSheet != null) {
            Provider.of<GameScoringProvider>(context, listen: false).privateComment = scoreSheet!.privateComment;
          }

          if (data.type == BlueprintType.agnostic) {
            if (scoreSheet != null) {
              Provider.of<GameScoringProvider>(context, listen: false).rawScore = scoreSheet!.score;
            }
            return AgnosticScoringWidget(
              onScoreChanged: (score, comment) {
                Provider.of<GameScoringProvider>(context, listen: false).score = score;
                Provider.of<GameScoringProvider>(context, listen: false).privateComment = comment;
              },
            );
          } else {
            if (scoreSheet != null) {
              Provider.of<GameScoringProvider>(context, listen: false).answers = scoreSheet!.scoreSheetAnswers;
            }
            return CustomScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      Mission mission = data.blueprint!.blueprint.robotGameMissions[index];
                      List<Question> allQuestions = data.blueprint!.blueprint.robotGameQuestions;
                      List<Question> missionQuestions = allQuestions.where((q) => q.id.startsWith(mission.id)).toList();

                      // Create a GlobalKey for each questions
                      questionKeys.addAll(List.generate(missionQuestions.length, (index) => GlobalKey()));

                      return MissionWidget(
                        mission: mission,
                        missionQuestions: missionQuestions.map((question) {
                          final key = questionKeys[allQuestions.indexOf(question)];
                          return QuestionWidget(
                            key: key,
                            question: question,
                            onAnswer: (a) {
                              _scrollToNextQuestion(questionKeys.indexOf(key));
                              Provider.of<GameScoringProvider>(context, listen: false).onAnswer(
                                QuestionAnswer(questionId: question.id, answer: a),
                              );
                            },
                          );
                        }).toList(),
                        season: data.blueprint!.title,
                      );
                    },
                    childCount: data.blueprint?.blueprint.robotGameMissions.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: PrivateCommentWidget(
                    comment: Provider.of<GameScoringProvider>(context).privateComment,
                    onCommentChanged: (c) {
                      Provider.of<GameScoringProvider>(context, listen: false).privateComment = c;
                    },
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
