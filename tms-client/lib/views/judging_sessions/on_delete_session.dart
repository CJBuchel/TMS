import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/judging_session_provider.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
import 'package:tms/widgets/dialogs/dialog_style.dart';

class OnDeleteSession {
  final String sessionNumber;

  OnDeleteSession({
    required this.sessionNumber,
  });

  void call(BuildContext context) {
    ConfirmFutureDialog(
      style: DialogStyle.error(
        title: "Delete Session $sessionNumber",
        message: const Text("Are you sure you want to delete this session?"),
      ),
      onStatusConfirmFuture: () {
        return Provider.of<JudgingSessionProvider>(context, listen: false).removeJudgingSession(sessionNumber);
      },
    ).show(context);
  }
}
