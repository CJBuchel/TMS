import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_status_provider.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/views/match_controller/match_selector/match_row/match_expandable_row.dart';
import 'package:tms/widgets/buttons/category_button.dart';
import 'package:tms/widgets/expandable/expandable_tile.dart';

class _MatchItemData {
  final GameMatch match;
  final List<GameMatch> loadedMatches;
  final bool canStage;

  _MatchItemData({
    required this.match,
    required this.loadedMatches,
    required this.canStage,
  });
}

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

    return Selector2<GameMatchProvider, GameMatchStatusProvider, _MatchItemData>(
      selector: (_, gameMatchProvider, statusProvider) {
        bool canStage = statusProvider.canStageMatch(
          gameMatchProvider.matches[listIndex].matchNumber,
          gameMatchProvider.matches,
        );
        List<GameMatch> loadedMatches = statusProvider.getLoadedMatches(
          gameMatchProvider.matches,
        );
        return _MatchItemData(
          match: gameMatchProvider.matches[listIndex],
          loadedMatches: loadedMatches,
          canStage: canStage,
        );
      },
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, data, _) {
        Color evenCompletedBackground = Colors.green[500] ?? Colors.green;
        Color oddCompletedBackground = Colors.green[300] ?? Colors.green;
        // alternating background colors

        Color evenBackground = data.match.completed ? evenCompletedBackground : Theme.of(context).cardColor;
        Color oddBackground =
            data.match.completed ? oddCompletedBackground : lighten(Theme.of(context).cardColor, 0.05);

        Color backgroundColor = listIndex.isEven ? evenBackground : oddBackground;
        Color submittedColor = listIndex.isEven ? evenCompletedBackground : oddCompletedBackground;

        // listenable builder for the expanded index
        return Theme(
          data: Theme.of(context).copyWith(
            iconTheme: Theme.of(context).iconTheme.copyWith(
                  color: data.match.completed ? Colors.black : null,
                ),
            textTheme: Theme.of(context).textTheme.apply(
                  bodyColor: data.match.completed ? Colors.black : null,
                  displayColor: data.match.completed ? Colors.black : null,
                ),
          ),
          child: MatchExpandableRow(
            match: data.match,
            loadedMatches: data.loadedMatches,
            isMultiMatch: isMultiMatch,
            canStage: data.canStage,
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
            submittedColor: submittedColor,
          ),
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
            return CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _matchItem(index, isMultiMatch);
                    },
                    childCount: matches.length,
                  ),
                ),
              ],
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
          textColor: Colors.white,
        ),
        CategoryButton(
          category: "Multi",
          onPressed: () => _isMultiMatch.value = true,
          selectedColor: Colors.purpleAccent,
          hoverColor: Colors.purple,
          textColor: Colors.white,
        ),
      ],
      defaultCategory: "Single",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _modeHeader(),
        Expanded(
          child: _matchList(),
        ),
      ],
    );
  }
}
