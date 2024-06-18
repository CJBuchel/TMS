import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/game_match_provider.dart';
import 'package:tms/schemas/database_schema.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/views/match_controller/match_table/match_table_item.dart';

class MatchTable extends StatelessWidget {
  const MatchTable({Key? key}) : super(key: key);

  Widget _matchItem(int index) {
    return Selector<GameMatchProvider, GameMatch>(
      selector: (_, provider) => provider.matches[index],
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, match, _) {
        return MatchTableItem(
          match: match,
          backgroundColor: index.isEven ? Theme.of(context).cardColor : lighten(Theme.of(context).cardColor, 0.05),
        );
      },
    );
  }

  Widget _matchList() {
    return Selector<GameMatchProvider, List<GameMatch>>(
      selector: (_, provider) => provider.matches,
      shouldRebuild: (previous, next) => previous.length != next.length,
      builder: (context, matches, _) {
        return ListView.builder(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            return _matchItem(index);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [":robot_game:matches"],
      child: _matchList(),
    );
  }
}
