import 'package:flutter/material.dart';
import 'package:tms_client/colors.dart';
import 'package:tms_client/utils/grpc_result.dart';
import 'package:tms_client/widgets/dialogs/base_dialog.dart';

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

  static SnackBarDialog fromGrpcStatus<T>({required GrpcResult<T> result}) {
    switch (result) {
      case GrpcSuccess():
        return SnackBarDialog.success(message: 'Success');
      case GrpcFailure(userMessage: final msg, statusCode: final code):
        String errorMessage = 'Failed: [$msg] With status: $code';
        return SnackBarDialog.error(message: errorMessage);
    }
  }

  @override
  void show(BuildContext context) {
    Color color;
    switch (type) {
      case DialogType.error:
        color = supportErrorColor;
        break;
      case DialogType.info:
        color = supportInfoColor;
        break;
      case DialogType.warn:
        color = supportWarningColor;
        break;
      case DialogType.success:
        color = supportSuccessColor;
        break;
    }

    final messenger = ScaffoldMessenger.of(context);
    // Clear any existing snackbars before showing new one
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(backgroundColor: color, content: Text(message)),
    );
  }
}
