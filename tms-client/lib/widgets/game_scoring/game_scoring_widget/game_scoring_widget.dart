import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/tournament_blueprint.dart';
import 'package:tms/generated/infra/network_schemas/tournament_config_requests.dart';
import 'package:tms/providers/tournament_blueprint_provider.dart';
import 'package:tms/providers/tournament_config_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/question/question.dart';

class _BlueprintData {
  final BlueprintType type;
  final TournamentBlueprint? blueprint;

  _BlueprintData({required this.type, required this.blueprint});
}

class GameScoringWidget extends StatelessWidget {
  const GameScoringWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [":tournament:blueprint", ":tournament:config"],
      child: Selector2<TournamentBlueprintProvider, TournamentConfigProvider, _BlueprintData>(
        selector: (context, bp, cp) {
          String blueprintTitle = cp.season;
          return _BlueprintData(type: cp.blueprintType, blueprint: bp.getBlueprint(blueprintTitle));
        },
        builder: (context, data, child) {
          if (data.type == BlueprintType.agnostic) {
            return Container(
              child: const Text('Agnostic Scoring'),
            );
          } else {
            return ListView.builder(
              itemCount: data.blueprint?.blueprint.robotGameQuestions.length,
              itemBuilder: (context, index) {
                return QuestionWidget(
                  question: data.blueprint!.blueprint.robotGameQuestions[index],
                  onAnswer: (a) {
                    TmsLogger().i('Answered question: ${a.questionId} with answer: ${a.answer}');
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
