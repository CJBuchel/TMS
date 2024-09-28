import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/category.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/tms_time/tms_date_time.dart';
import 'package:tms/generated/infra/database_schemas/tms_time/tms_duration.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/utils/tms_time_utils.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
import 'package:tms/widgets/edit_time.dart';

class OnAddMatch {
  final TextEditingController _matchNumberController = TextEditingController();

  TmsDateTime _startTime = dateTimeToTmsDateTime(DateTime.now());

  Widget _rowPadding(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: child,
    );
  }

  Widget _editStartTime() {
    return EditTimeWidget(
      label: "Start Time",
      initialTime: dateTimeToTmsDateTime(DateTime.now()),
      onChanged: (t) => _startTime = t,
    );
  }

  void call(BuildContext context) {
    ConfirmFutureDialog(
      onStatusConfirmFuture: () {
        return Provider.of<GameMatchProvider>(context, listen: false).insertGameMatch(
          null,
          GameMatch(
            matchNumber: _matchNumberController.text,
            startTime: _startTime,
            endTime: _startTime.addDuration(duration: TmsDuration(minutes: 7)),
            completed: false,
            gameMatchTables: [],
            category: const TmsCategory(category: "Ranking Matches", subCategories: []),
          ),
        );
      },
      style: ConfirmDialogStyle.success(
        title: "Add Match",
        message: Column(
          children: [
            _editStartTime(),
            // don't need to add end time (useful for now)
            _rowPadding(
              TextField(
                controller: _matchNumberController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Match Number",
                ),
              ),
            ),
          ],
        ),
      ),
    ).show(context);
  }
}
