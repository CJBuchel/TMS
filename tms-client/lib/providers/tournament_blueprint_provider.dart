import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:tms/generated/infra/database_schemas/tournament_blueprint.dart';
import 'package:tms/generated/infra/fll_infra/fll_blueprint.dart';

class TournamentBlueprintProvider extends EchoTreeProvider<String, TournamentBlueprint> {
  TournamentBlueprintProvider()
      : super(tree: ":tournament:blueprint", fromJsonString: (json) => TournamentBlueprint.fromJsonString(json: json));

  List<TournamentBlueprint> get blueprints {
    return this.items.values.toList();
  }

  List<String> get blueprintTitles {
    return this.items.map((key, value) => MapEntry(key, value.title)).values.toList();
  }

  TournamentBlueprint getBlueprint(String blueprintTitle) {
    // find blueprint from blueprint title
    try {
      return blueprints.firstWhere((t) => t.title == blueprintTitle);
    } catch (e) {
      return const TournamentBlueprint(
        title: 'N/A',
        blueprint: FllBlueprint(
          robotGameQuestions: [],
          robotGameMissions: [],
        ),
      );
    }
  }
}
