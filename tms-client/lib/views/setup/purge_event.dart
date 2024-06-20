import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/event_config_provider.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/popup_dialog.dart';

class PurgeButton extends StatelessWidget {
  void _confirmDialog(BuildContext context, EventConfigProvider provider) {
    ConfirmDialog(
      style: ConfirmDialogStyle.error(
        title: "Confirm Purge?",
        message: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Purging an event will delete all teams, matches and more..."),
          ],
        ),
      ),
      onConfirm: () async {
        await provider.purgeEvent().then((res) {
          if (res != HttpStatus.ok) {
            PopupDialog.error(title: "Error", message: "Failed to purge event").show(context);
          } else {
            PopupDialog.success(title: "Success", message: "Successfully purged event").show(context);
          }
        });
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventConfigProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 70,
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          child: ElevatedButton(
            style: ButtonStyle(
              textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.headlineSmall),
              backgroundColor: MaterialStateProperty.all(Colors.red),
              overlayColor: MaterialStateProperty.all(Colors.redAccent),
              // text color
              foregroundColor: MaterialStateProperty.all(Colors.white),
              // border color
              side: MaterialStateProperty.all(const BorderSide(color: Colors.black)),
            ),
            onPressed: () => _confirmDialog(context, provider),
            child: const Text("PURGE"),
          ),
        );
      },
    );
  }
}
