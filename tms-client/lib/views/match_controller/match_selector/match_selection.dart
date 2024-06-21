import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/game_match_provider.dart';
import 'package:tms/schemas/database_schema.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/views/match_controller/match_selector/match_row/match_expandable_row.dart';
import 'package:tms/widgets/buttons/category_button.dart';
import 'package:tms/widgets/expandable/expandable_tile.dart';

class MatchSelection extends StatelessWidget {
  MatchSelection({Key? key}) : super(key: key);

  // expansion controllers for each match item
  final List<ExpansionController> _controllers = [];

  // multi match trigger
  final ValueNotifier<bool> _isMultiMatch = ValueNotifier<bool>(false);

  Widget _matchItem(int listIndex, bool isMultiMatch) {
    if (listIndex >= _controllers.length) {
      _controllers.add(ExpansionController(isExpanded: false));
    }

    return Selector<GameMatchProvider, GameMatch>(
      selector: (_, provider) => provider.matches[listIndex],
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, match, _) {
        // alternating background colors
        Color evenBackground = Theme.of(context).cardColor;
        Color oddBackground = lighten(Theme.of(context).cardColor, 0.05);

        Color backgroundColor = listIndex.isEven ? evenBackground : oddBackground;

        // listenable builder for the expanded index
        return MatchExpandableRow(
          match: match,
          isMultiMatch: isMultiMatch,
          controller: _controllers[listIndex],
          onChangeExpand: (isExpanded) {
            if (isExpanded) {
              _controllers.forEach((element) {
                if (element != _controllers[listIndex]) {
                  element.collapse();
                }
              });
            }
          },
          backgroundColor: backgroundColor,
        );
      },
    );
  }

  Widget _matchList() {
    return Selector<GameMatchProvider, List<GameMatch>>(
      selector: (_, provider) => provider.matches,
      shouldRebuild: (previous, next) => previous.length != next.length,
      builder: (context, matches, _) {
        return ValueListenableBuilder(
          valueListenable: _isMultiMatch,
          builder: (context, isMultiMatch, _) {
            return ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                return _matchItem(index, isMultiMatch);
              },
            );
          },
        );
      },
    );
  }

  Widget _modeHeader() {
    return CategoryButtons(
      buttons: [
        CategoryButton(
          category: "Single",
          onPressed: () => _isMultiMatch.value = false,
          selectedColor: Colors.blue,
          hoverColor: Colors.blueAccent,
        ),
        CategoryButton(
          category: "Multi",
          onPressed: () => _isMultiMatch.value = true,
          selectedColor: Colors.purpleAccent,
          hoverColor: Colors.purple,
        ),
      ],
      defaultCategory: "Single",
    );
  }

  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [":robot_game:matches"],
      child: Column(
        children: [
          _modeHeader(),
          Expanded(
            child: _matchList(),
          ),
        ],
      ),
    );
  }
}
