import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/category.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/robot_game_providers/game_category_provider.dart';
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
  final ValueNotifier<TmsCategory?> _selectedCategory = ValueNotifier<TmsCategory?>(null);

  Widget _matchItem(TmsCategory? category, int listIndex, bool isMultiMatch) {
    if (listIndex >= _controllers.length) {
      _controllers.add(ExpansionController(isExpanded: false));
    }

    return Selector2<GameMatchProvider, GameMatchStatusProvider, _MatchItemData>(
      selector: (_, gameMatchProvider, statusProvider) {
        List<GameMatch> matches = [];
        if (category != null) {
          matches = gameMatchProvider.getMatchesByCategory(
            category: category.category,
            subCategories: category.subCategories,
          );
        } else {
          matches = gameMatchProvider.matches;
        }

        bool canStage = statusProvider.canStageMatch(
          matches[listIndex].matchNumber,
          matches,
        );
        List<GameMatch> loadedMatches = statusProvider.getLoadedMatches(
          matches,
        );
        return _MatchItemData(
          match: matches[listIndex],
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
    return ValueListenableBuilder(
      valueListenable: _selectedCategory,
      builder: (context, category, _) {
        return Selector<GameMatchProvider, List<GameMatch>>(
          selector: (_, provider) {
            if (_selectedCategory.value != null) {
              return provider.getMatchesByCategory(
                category: _selectedCategory.value!.category,
              );
            } else {
              return provider.matches;
            }
          },
          shouldRebuild: (previous, next) => previous.length != next.length,
          builder: (context, matches, _) {
            return ValueListenableBuilder(
              valueListenable: _isMultiMatch,
              builder: (context, isMultiMatch, _) {
                return ListView.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    return _matchItem(_selectedCategory.value, index, isMultiMatch);
                  },
                );
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

  Widget _categoryHeader() {
    // display dropdown for category selection
    return Selector<GameCategoryProvider, List<TmsCategory>>(
      selector: (context, provider) => provider.categories,
      builder: (context, data, _) {
        if (data.isEmpty) {
          return const SizedBox();
        }

        // post frame callback to set the selected category
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_selectedCategory.value == null && data.isNotEmpty) {
            if (!data.contains(_selectedCategory.value)) _selectedCategory.value = data.first;
          }
        });

        return Container(
          padding: const EdgeInsets.all(8),
          child: DropdownSearch<TmsCategory>(
            selectedItem: _selectedCategory.value,
            items: data,
            itemAsString: (cat) => cat.category,
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(20),
                labelText: "Category",
                hintText: "Select Category",
              ),
            ),
            onChanged: (value) {
              if (value != null) _selectedCategory.value = value;
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _modeHeader(),
        _categoryHeader(),
        Expanded(
          child: _matchList(),
        ),
      ],
    );
  }
}
