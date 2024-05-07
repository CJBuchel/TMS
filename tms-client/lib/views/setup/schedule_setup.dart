import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/schedule_provider.dart';
import 'package:tms/views/setup/input_setter.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/popup_dialog.dart';

class ScheduleSetup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<ScheduleProvider>(
          builder: (context, provider, child) {
            return InputSetter(
              label: "Upload Schedule:",
              onSet: () async {
                await provider.uploadSchedule().then((_) {
                  PopupDialog.success(title: "Success", message: "Successfully uploaded schedule").show(context);
                });
              },
              confirmDialogStyle: ConfirmDialogStyle.warn(
                title: "Confirm Upload?",
                message: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Uploading a schedule can overwrite existing teams, matches and judging sessions"),
                  ],
                ),
              ),
              input: ElevatedButton(
                onPressed: () async {
                  await provider.selectCSV();
                },
                child: Text(provider.result == null ? "Select CSV" : provider.result?.files.first.name ?? ""),
              ),
            );
          },
        ),
      ],
    );
  }
}
