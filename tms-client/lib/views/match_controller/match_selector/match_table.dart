import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/game_match_provider.dart';
import 'package:tms/schemas/database_schema.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/views/match_controller/match_selector/match_table_item.dart';
import 'package:tms/widgets/expandable/expandable_tile.dart';

class MatchTable extends StatelessWidget {
  MatchTable({Key? key}) : super(key: key);

  // expansion controllers for each match item
  final List<ExpansionController> _controllers = [];

  Widget _matchItem(int listIndex) {
    if (listIndex >= _controllers.length) {
      _controllers.add(ExpansionController(isExpanded: false));
    }

    return Selector<GameMatchProvider, GameMatch>(
      selector: (_, provider) => provider.matches[listIndex],
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, match, _) {
        // listenable builder for the expanded index
        return MatchTableItem(
          match: match,
          controller: _controllers[listIndex],
          onChange: (isExpanded) {
            if (isExpanded) {
              _controllers.forEach((element) {
                if (element != _controllers[listIndex]) {
                  element.collapse();
                }
              });
            }
          },
          backgroundColor: listIndex.isEven ? Theme.of(context).cardColor : lighten(Theme.of(context).cardColor, 0.05),
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
