import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/game_match_provider.dart';
import 'package:tms/utils/tms_time_utils.dart';
import 'package:tms/views/match_controller/match_selector/match_row/expanded_row_body/expanded_row_body.dart';
import 'package:tms/views/match_controller/match_selector/match_row/stage_checkbox.dart';
import 'package:tms/views/match_controller/match_selector/match_row/table_info.dart';
import 'package:tms/widgets/animated/barber_pole_container.dart';
import 'package:tms/widgets/expandable/expandable_tile.dart';

enum MatchRowState {
  IDLE, // default, blank
  STAGED, // blue
  LOADED, // orange
  RUNNING, // green
}

class MatchExpandableRow extends StatelessWidget {
  final GameMatch match;
  final bool isMultiMatch;
  final Color? backgroundColor;
  final Function(bool)? onChangeExpand;
  final Function(bool)? onSelect;
  final ExpansionController? controller;

  MatchExpandableRow({
    Key? key,
    required this.match,
    required this.isMultiMatch,
    this.backgroundColor,
    this.controller,
    this.onChangeExpand,
    this.onSelect,
  }) : super(key: key);

  Widget _leading(MatchRowState state) {
    Color? color = null;
    if (state == MatchRowState.STAGED) color = Colors.white;
    if (state == MatchRowState.LOADED) color = Colors.white;

    return SizedBox(
      width: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.sports_esports, color: color),
          const SizedBox(width: 10),
          Column(
            children: [
              Text("#${match.matchNumber}", style: TextStyle(color: color)),
              const SizedBox(height: 10),
              Text(tmsDateTimeToString(match.startTime), style: TextStyle(fontSize: 12, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trailing(MatchRowState state) {
    Color? color = null;
    if (state == MatchRowState.STAGED) color = Colors.white;
    if (state == MatchRowState.LOADED) color = Colors.white;

    return ValueListenableBuilder(
      valueListenable: controller ?? ExpansionController(),
      builder: (context, isExpanded, child) {
        return isExpanded ? Icon(Icons.expand_more, color: color) : Icon(Icons.chevron_right, color: color);
      },
    );
  }

  Widget _central() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: match.gameMatchTables.map((table) {
        return TableItem(
          isMatchComplete: match.completed,
          table: table,
          backgroundColor: backgroundColor,
        );
      }).toList(),
    );
  }

  Widget _tileRow(MatchRowState state, List<GameMatch> loadedMatches) {
    bool isLoaded = state == MatchRowState.LOADED;
    bool isExpandable = !isMultiMatch && !isLoaded;

    return ExpandableTile(
      controller: controller,
      onChange: onChangeExpand,
      header: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // optional checkbox (multi match only)
            if (isMultiMatch && loadedMatches.isEmpty) StageCheckbox(match: match),

            // leading
            _leading(state),

            // central/main info
            Expanded(
              child: _central(),
            ),

            // trailing
            if (isExpandable) _trailing(state),
          ],
        ),
      ),
      body: isExpandable ? ExpandedRowBody(match: match, loadedMatches: loadedMatches) : const SizedBox.shrink(),
    );
  }

  Color _stateColor(MatchRowState state) {
    switch (state) {
      case MatchRowState.STAGED:
        return const Color(0xFF1976D2);
      case MatchRowState.LOADED:
        return const Color(0xFFD55C00);
      case MatchRowState.RUNNING:
        return const Color(0xFF388E3C);
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.black;

    return Card(
      margin: const EdgeInsets.all(5),
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor),
      ),
      // provider selector
      child: Selector<
          GameMatchProvider,
          ({
            bool isMatchStaged,
            bool isMatchLoaded,
            bool isMatchRunning,
            List<GameMatch> loadedMatches,
          })>(
        selector: (context, provider) {
          return (
            isMatchStaged: provider.isMatchStaged(match.matchNumber),
            isMatchLoaded: provider.isMatchLoaded(match.matchNumber),
            isMatchRunning: provider.isMatchRunning(match.matchNumber),
            loadedMatches: provider.loadedMatches,
          );
        },
        builder: (context, data, child) {
          MatchRowState state = MatchRowState.STAGED;
          if (data.isMatchRunning) {
            state = MatchRowState.RUNNING;
          } else if (data.isMatchLoaded) {
            state = MatchRowState.LOADED;
          } else if (data.isMatchStaged) {
            state = MatchRowState.STAGED;
          } else {
            state = MatchRowState.IDLE;
          }

          if (state != MatchRowState.IDLE && state != MatchRowState.STAGED) {
            return BarberPoleContainer(
              active: true,
              stripeColor: _stateColor(state),
              color: Colors.grey[800],
              hoverColor: Colors.grey[700],
              borderRadius: BorderRadius.circular(8),
              child: _tileRow(state, data.loadedMatches),
            );
          } else {
            return BarberPoleContainer(
              active: false,
              color: _stateColor(state),
              borderRadius: BorderRadius.circular(8),
              child: _tileRow(state, data.loadedMatches),
            );
          }
        },
      ),
    );
  }
}
