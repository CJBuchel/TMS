import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/providers/robot_game_providers/game_table_provider.dart';
import 'package:tms/models/timer_match_data.dart';

class GameMatchTimerHeader extends StatelessWidget {
  final TimerMatchData data;
  const GameMatchTimerHeader({
    Key? key,
    required this.data,
  }) : super(key: key);

  String _getMatchSummary(List<GameMatch> loadedMatches, GameMatch? nextMatch) {
    if (loadedMatches.isEmpty) {
      if (nextMatch == null) {
        return "No Matches";
      } else {
        String t = nextMatch.startTime.toString();
        return "Next Match: ${nextMatch.matchNumber} - $t";
      }
    } else {
      // get the first match for cat/sub cat
      GameMatch? first = loadedMatches.first;
      String matchNumbers = loadedMatches.map((m) => m.matchNumber).join(", ");
      return "${first.category.category}: ${matchNumbers}";
    }
  }

  Widget _dropDownTableSelector(BuildContext context) {
    return Selector<GameTableProvider, List<String>>(
      selector: (context, provider) => provider.tables.map((t) => t.tableName).toList(),
      builder: (context, tables, _) {
        // list of initial tables, if they're in the tables list
        List<String> initialTables = TmsLocalStorageProvider().timerAssignedTables.where((t) {
          return tables.contains(t);
        }).toList();

        return MultiSelectDialogField(
          initialValue: initialTables,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          buttonText: const Text("Assign Timer to Table/s"),
          buttonIcon: const Icon(Icons.table_bar),
          title: const Text("Assign Timer to Table/s"),
          listType: MultiSelectListType.CHIP,
          items: tables.map((t) => MultiSelectItem(t, t)).toList(),
          onConfirm: (List<String> tables) {
            TmsLocalStorageProvider().timerAssignedTables = tables;
          },
        );
      },
    );
  }

  Widget _tableSector(BuildContext context) {
    if (ResponsiveBreakpoints.of(context).isDesktop) {
      return Container(
        width: ResponsiveBreakpoints.of(context).screenWidth * 0.3,
        padding: const EdgeInsets.only(right: 10, top: 10),
        child: _dropDownTableSelector(context),
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white;

    double fontSize = 20;
    double edgeInsets = 20;

    if (ResponsiveBreakpoints.of(context).isDesktop) {
      fontSize = 20;
      edgeInsets = 20;
    } else if (ResponsiveBreakpoints.of(context).isTablet) {
      fontSize = 18;
      edgeInsets = 10;
    } else if (ResponsiveBreakpoints.of(context).isMobile) {
      fontSize = 16;
      edgeInsets = 5;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(edgeInsets),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(20),
            ),
            border: Border(
              bottom: BorderSide(
                color: borderColor,
                width: 2,
              ),
              right: BorderSide(
                color: borderColor,
                width: 2,
              ),
            ),
          ),
          child: Text(
            _getMatchSummary(data.loadedMatches, data.nextMatch),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ),
        _tableSector(context),
      ],
    );
  }
}
