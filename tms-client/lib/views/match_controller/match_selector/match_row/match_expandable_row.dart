import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/tournament_integrity_message.dart';
import 'package:tms/providers/robot_game_providers/game_match_status_provider.dart';
import 'package:tms/views/match_controller/match_selector/match_row/expanded_row_body/expanded_row_body.dart';
import 'package:tms/views/match_controller/match_selector/match_row/stage_checkbox.dart';
import 'package:tms/views/match_controller/match_selector/match_row/table_info.dart';
import 'package:tms/widgets/animated/barber_pole_container.dart';
import 'package:tms/widgets/expandable/expandable_tile.dart';
import 'package:tms/widgets/integrity_checks/icon_tooltip_integrity_check.dart';

class _MatchRowData {
  final bool isMatchStaged;
  final bool isMatchLoaded;
  final bool isMatchRunning;
  final List<GameMatch> loadedMatches;

  _MatchRowData({
    required this.isMatchStaged,
    required this.isMatchLoaded,
    required this.isMatchRunning,
    required this.loadedMatches,
  });
}

enum MatchRowState {
  IDLE, // default, blank
  STAGED, // blue
  LOADED, // orange
  RUNNING, // green
}

class MatchExpandableRow extends StatelessWidget {
  final GameMatch match;
  final List<GameMatch> loadedMatches;
  final List<TournamentIntegrityMessage> integrityMessages;
  final bool isMultiMatch;
  final bool canStage;
  final Color? backgroundColor;
  final Color? submittedColor;
  final Function(bool)? onChangeExpand;
  final Function(bool)? onSelect;
  final ExpansionController? controller;

  MatchExpandableRow({
    Key? key,
    required this.match,
    required this.loadedMatches,
    required this.integrityMessages,
    required this.isMultiMatch,
    required this.canStage,
    this.backgroundColor,
    this.submittedColor,
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
          integrityMessages.isEmpty
              ? Icon(Icons.sports_esports, color: color)
              : IconTooltipIntegrityCheck(messages: integrityMessages),
          const SizedBox(width: 10),
          Column(
            children: [
              Text("#${match.matchNumber}", style: TextStyle(color: color)),
              const SizedBox(height: 10),
              Text(match.startTime.toString(), style: TextStyle(fontSize: 12, color: color)),
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
          submittedColor: submittedColor ?? Colors.green,
        );
      }).toList(),
    );
  }

  Widget _tileRow(MatchRowState state, List<GameMatch> loadedMatches, bool canStage, bool isStaged) {
    bool isLoaded = state == MatchRowState.LOADED;
    bool isRunning = state == MatchRowState.RUNNING;
    bool isExpandable = !isMultiMatch && !isLoaded && !isRunning;

    return ExpandableTile(
      controller: controller,
      onChange: onChangeExpand,
      header: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // optional checkbox (multi match only)
            if (isMultiMatch && loadedMatches.isEmpty)
              StageCheckbox(
                match: match,
                canStage: canStage,
                isStaged: isStaged,
              ),

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
      body: isExpandable
          ? ExpandedRowBody(
              match: match,
              isStaged: isStaged,
            )
          : const SizedBox.shrink(),
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
      child: Selector<GameMatchStatusProvider, _MatchRowData>(
        selector: (context, statusProvider) {
          return _MatchRowData(
            isMatchStaged: statusProvider.isMatchStaged(match.matchNumber),
            isMatchLoaded: statusProvider.isMatchLoaded(match.matchNumber),
            isMatchRunning: statusProvider.isMatchRunning(match.matchNumber),
            loadedMatches: loadedMatches,
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
              child: _tileRow(state, data.loadedMatches, canStage, data.isMatchStaged),
            );
          } else {
            return BarberPoleContainer(
              active: false,
              color: _stateColor(state),
              borderRadius: BorderRadius.circular(8),
              child: _tileRow(state, data.loadedMatches, canStage, data.isMatchStaged),
            );
          }
        },
      ),
    );
  }
}
