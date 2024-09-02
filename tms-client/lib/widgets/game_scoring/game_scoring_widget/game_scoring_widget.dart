import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/tournament_blueprint.dart';
import 'package:tms/generated/infra/fll_infra/mission.dart';
import 'package:tms/generated/infra/fll_infra/question.dart';
import 'package:tms/generated/infra/network_schemas/tournament_config_requests.dart';
import 'package:tms/providers/tournament_blueprint_provider.dart';
import 'package:tms/providers/tournament_config_provider.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/agnostic_scoring/agnostic_scoring.dart';
import 'package:tms/widgets/game_scoring/game_scoring_widget/blueprint_scoring/mission.dart';

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
            return AgnosticScoringWidget();
          } else {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: data.blueprint?.blueprint.robotGameMissions.length,
              itemBuilder: (context, index) {
                Mission mission = data.blueprint!.blueprint.robotGameMissions[index];
                List<Question> allQuestions = data.blueprint!.blueprint.robotGameQuestions;
                List<Question> missionQuestions = allQuestions.where((q) => q.id.startsWith(mission.id)).toList();
                return MissionWidget(
                  mission: mission,
                  missionQuestions: missionQuestions,
                  season: data.blueprint!.title,
                );
              },
            );
          }
        },
      ),
    );
  }
}
