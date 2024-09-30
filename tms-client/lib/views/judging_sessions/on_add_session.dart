import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/category.dart';
import 'package:tms/generated/infra/database_schemas/judging_session.dart';
import 'package:tms/generated/infra/database_schemas/tms_time/tms_date_time.dart';
import 'package:tms/generated/infra/database_schemas/tms_time/tms_duration.dart';
import 'package:tms/providers/judging_session_provider.dart';
import 'package:tms/utils/tms_time_utils.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
import 'package:tms/widgets/edit_time.dart';

class OnAddSession {
  final TextEditingController _sessionNameController = TextEditingController();

  TmsDateTime _startTime = dateTimeToTmsDateTime(DateTime.now());
  TmsDateTime _endTime = dateTimeToTmsDateTime(DateTime.now());

  Widget _rowPadding(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: child,
    );
  }

  Widget _editStartTime() {
    return EditTimeWidget(
      label: "Start Time",
      initialTime: TmsDateTime(time: dateTimeToTmsDateTime(DateTime.now()).time),
      onChanged: (t) => _startTime = t,
    );
  }

  Widget _editEndTime() {
    return EditTimeWidget(
      label: "End Time",
      initialTime: TmsDateTime(time: dateTimeToTmsDateTime(DateTime.now()).time).addDuration(
        duration: TmsDuration(
          minutes: 30,
        ),
      ),
      onChanged: (t) => _endTime = t,
    );
  }

  void call(BuildContext context) {
    ConfirmFutureDialog(
      onStatusConfirmFuture: () {
        if (_sessionNameController.text.isEmpty) {
          return Future.value(HttpStatus.badRequest);
        } else {
          return Provider.of<JudgingSessionProvider>(context, listen: false).insertJudgingSession(
            null,
            JudgingSession(
              sessionNumber: _sessionNameController.text,
              startTime: TmsDateTime(time: _startTime.time), // we only care about time, not date
              endTime: TmsDateTime(time: _endTime.time),
              completed: false,
              judgingSessionPods: [],
              category: const TmsCategory(category: "", subCategories: []),
            ),
          );
        }
      },
      style: ConfirmDialogStyle.success(
        title: "Add Session",
        message: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _rowPadding(_editStartTime()),
            _rowPadding(_editEndTime()),
            _rowPadding(
              TextField(
                controller: _sessionNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Session Number",
                ),
              ),
            ),
          ],
        ),
      ),
    ).show(context);
  }
}
