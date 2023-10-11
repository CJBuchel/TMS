import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/matches/add_match/add_match.dart';
import 'package:tms/views/admin/dashboard/matches/checks/errors.dart';
import 'package:tms/views/admin/dashboard/matches/checks/warnings.dart';
import 'package:tms/views/admin/dashboard/matches/match_edit_row.dart';

class MatchEditTable extends StatelessWidget {
  final List<GameMatch> matches;
  final List<Team> teams;
  final Function() requestMatches;
  final List<MatchWarning> warnings;
  final List<MatchError> errors;
  const MatchEditTable({
    Key? key,
    required this.matches,
    required this.teams,
    required this.requestMatches,
    required this.errors,
    required this.warnings,
  }) : super(key: key);

  Widget _topButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            requestMatches();
          },
          icon: const Icon(Icons.refresh, color: Colors.orange),
        ),

        // add match
        AddMatch(matches: matches),
      ],
    );
  }

  Widget _getTable() {
    // list view table
    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        bool isDeferred = matches[index].gameMatchDeferred;
        bool isComplete = matches[index].complete;

        Color rowColor = Colors.transparent; // default

        if (isDeferred) {
          rowColor = Colors.cyan;
        } else if (index.isEven) {
          if (isComplete) {
            rowColor = Colors.green;
          } else {
            rowColor = Theme.of(context).splashColor;
          }
        } else {
          if (isComplete) {
            rowColor = Colors.green[300] ?? Colors.green;
          } else {
            rowColor = Theme.of(context).colorScheme.secondary.withOpacity(0.1);
          }
        }

        return MatchEditRow(
          match: matches[index],
          teams: teams,
          rowColor: rowColor,
          warnings: warnings,
          errors: errors,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: ((context, constraints) {
      return Column(
        children: [
          SizedBox(
            height: 50,
            child: _topButtons(),
          ),

          // main table
          Expanded(
            child: SizedBox(
              width: constraints.maxWidth * 0.9,
              child: _getTable(),
            ),
          ),
        ],
      );
    }));
  }
}
