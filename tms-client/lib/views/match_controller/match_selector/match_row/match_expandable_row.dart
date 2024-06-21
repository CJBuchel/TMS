import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/game_match_provider.dart';
import 'package:tms/schemas/database_schema.dart';
import 'package:tms/utils/tms_date_time.dart';
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

  Widget _leading() {
    return SizedBox(
      width: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(Icons.sports_esports),
          const SizedBox(width: 10),
          Column(
            children: [
              Text("#${match.matchNumber}"),
              const SizedBox(height: 10),
              Text(tmsDateTimeToString(match.startTime), style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trailing() {
    return ValueListenableBuilder(
      valueListenable: controller ?? ExpansionController(),
      builder: (context, isExpanded, child) {
        return isExpanded ? const Icon(Icons.expand_more) : const Icon(Icons.chevron_right);
      },
    );
  }

  Widget _central() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: match.gameMatchTables.map((table) {
        return TableItem(
          table: table,
          backgroundColor: backgroundColor,
        );
      }).toList(),
    );
  }

  bool get _isExpandable {
    return !isMultiMatch;
  }

  Widget _tileRow() {
    return ExpandableTile(
      controller: controller,
      onChange: onChangeExpand,
      header: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // optional checkbox (multi match only)
            if (isMultiMatch) StageCheckbox(match: match),

            // leading
            _leading(),

            // central/main info
            Expanded(
              child: _central(),
            ),

            // trailing
            if (!isMultiMatch) _trailing(),
          ],
        ),
      ),
      body: _isExpandable ? ExpandedRowBody(match: match) : const SizedBox.shrink(),
    );
  }

  Color _stateColor(MatchRowState state) {
    switch (state) {
      case MatchRowState.STAGED:
        return Colors.blue[700] ?? Colors.blue;
      case MatchRowState.LOADED:
        return Colors.orange[700] ?? Colors.orange;
      case MatchRowState.RUNNING:
        return Colors.green[700] ?? Colors.green;
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
      child: Selector<GameMatchProvider, bool>(
        selector: (context, provider) => provider.isMatchStaged(match.matchNumber),
        builder: (context, isSelected, child) {
          MatchRowState state = MatchRowState.STAGED;
          if (isSelected) {
            state = MatchRowState.STAGED;
          } else {
            state = MatchRowState.IDLE;
          }

          return BarberPoleContainer(
            active: state != MatchRowState.IDLE,
            stripeColor: _stateColor(state),
            borderRadius: BorderRadius.circular(8),
            child: _tileRow(),
          );
        },
      ),
    );
  }
}
