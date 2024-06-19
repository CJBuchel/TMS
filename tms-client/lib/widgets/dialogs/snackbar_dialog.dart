import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/utils/http_status_to_message.dart';
import 'package:tms/widgets/dialogs/base_dialog.dart';

class SnackBarDialog extends BaseDialog {
  final String message;
  final DialogType type;

  SnackBarDialog({required this.message, required this.type});

  factory SnackBarDialog.info({required String message}) {
    return SnackBarDialog(message: message, type: DialogType.info);
  }

  factory SnackBarDialog.success({required String message}) {
    return SnackBarDialog(message: message, type: DialogType.success);
  }

  factory SnackBarDialog.error({required String message}) {
    return SnackBarDialog(message: message, type: DialogType.error);
  }

  factory SnackBarDialog.warn({required String message}) {
    return SnackBarDialog(message: message, type: DialogType.warn);
  }

  factory SnackBarDialog.fromStatus({required String message, required int status}) {
    String statusMessage = HttpStatusToMessage().getMessage(status);
    if (status != HttpStatus.ok) {
      String errorMessage = "Failed: [$message], with status: $statusMessage";
      return SnackBarDialog.error(message: errorMessage);
    } else {
      String successMessage = "Success: $message";
      return SnackBarDialog.success(message: successMessage);
    }
  }

  @override
  void show(BuildContext context) {
    Color color;
    switch (type) {
      case DialogType.error:
        color = Colors.red;
        break;
      case DialogType.info:
        color = Colors.blue;
        break;
      case DialogType.warn:
        color = Colors.orange;
        break;
      case DialogType.success:
        color = Colors.green;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(message),
      ),
    );
  }
}
