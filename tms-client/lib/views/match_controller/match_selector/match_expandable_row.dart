import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/game_match_provider.dart';
import 'package:tms/schemas/database_schema.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/utils/tms_date_time.dart';
import 'package:tms/views/match_controller/match_selector/match_row_body.dart';
import 'package:tms/widgets/animated/barber_pole_container.dart';
import 'package:tms/widgets/buttons/live_checkbox.dart';
import 'package:tms/widgets/expandable/expandable_tile.dart';

enum MatchRowState {
  UNSELECTED, // default, blank
  SELECTED, // blue
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

  Widget _checkBoxSelect(BuildContext context) {
    GameMatchProvider provider = Provider.of<GameMatchProvider>(context, listen: false);
    bool isStaged = provider.isMatchStaged(match);

    return LiveCheckbox(
      defaultValue: isStaged,
      onChanged: (value) {
        if (value) {
          provider.addMatchToStage(match);
        } else {
          provider.removeMatchFromStage(match);
        }
      },
    );
  }

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

  Widget _tableInfo(GameMatchTable table, Color borderColor) {
    return Expanded(
      flex: 1,
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.blue),
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
          color: lighten(backgroundColor ?? Colors.white, 0.05),
        ),
        child: Column(
          children: [
            Text(table.table),
            const SizedBox(height: 10),
            Text(table.teamNumber, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _central(Color borderColor) {
    List<Widget> children = [];

    for (GameMatchTable table in match.gameMatchTables) {
      children.add(_tableInfo(table, borderColor));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: children,
    );
  }

  bool get _isExpandable {
    return !isMultiMatch;
  }

  Widget _tileRow(BuildContext context, Color borderColor) {
    return ExpandableTile(
      controller: controller,
      onChange: onChangeExpand,
      header: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // optional checkbox (multi match only)
            if (isMultiMatch) _checkBoxSelect(context),

            // leading
            _leading(),

            // central/main info
            Expanded(
              child: _central(borderColor),
            ),

            // trailing
            if (!isMultiMatch) _trailing(),
          ],
        ),
      ),
      body: _isExpandable ? MatchRowBody() : const SizedBox.shrink(),
    );
  }

  Color _stateColor(MatchRowState state) {
    switch (state) {
      case MatchRowState.SELECTED:
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
        selector: (context, provider) => provider.isMatchStaged(match),
        builder: (context, isSelected, child) {
          MatchRowState state = MatchRowState.UNSELECTED;
          if (isSelected) {
            state = MatchRowState.SELECTED;
          } else {
            state = MatchRowState.UNSELECTED;
          }

          return BarberPoleContainer(
            active: state != MatchRowState.UNSELECTED,
            stripeColor: _stateColor(state),
            borderRadius: BorderRadius.circular(8),
            child: _tileRow(context, borderColor),
          );
        },
      ),
    );
  }
}
