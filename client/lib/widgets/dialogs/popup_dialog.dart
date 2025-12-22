import 'package:flutter/material.dart';
import 'package:tms_client/colors.dart';
import 'package:tms_client/utils/grpc_result.dart';
import 'package:tms_client/widgets/dialogs/base_dialog.dart';

class PopupDialog extends BaseDialog {
  final String title;
  final Widget message;
  final DialogType type;
  final List<Widget>? actions;

  PopupDialog({
    required this.title,
    required this.message,
    required this.type,
    this.actions,
  });

  factory PopupDialog.info({
    required String title,
    required Widget message,
    List<Widget>? actions,
  }) {
    return PopupDialog(
      title: title,
      message: message,
      type: DialogType.info,
      actions: actions,
    );
  }

  factory PopupDialog.success({
    required String title,
    required Widget message,
    List<Widget>? actions,
  }) {
    return PopupDialog(
      title: title,
      message: message,
      type: DialogType.success,
      actions: actions,
    );
  }

  factory PopupDialog.error({
    required String title,
    required Widget message,
    List<Widget>? actions,
  }) {
    return PopupDialog(
      title: title,
      message: message,
      type: DialogType.error,
      actions: actions,
    );
  }

  factory PopupDialog.warn({
    required String title,
    required Widget message,
    List<Widget>? actions,
  }) {
    return PopupDialog(
      title: title,
      message: message,
      type: DialogType.warn,
      actions: actions,
    );
  }

  static PopupDialog fromGrpcStatus<T>({
    required GrpcResult<T> result,
    Widget? successMessage,
  }) {
    switch (result) {
      case GrpcSuccess():
        return PopupDialog.success(
          title: 'Success',
          message: successMessage ?? const Text('Success'),
        );
      case GrpcFailure(userMessage: final msg, statusCode: final code):
        return PopupDialog.error(
          title: 'Error',
          message: Column(
            children: [
              Text(
                'Status: $code',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Failed: $msg'),
            ],
          ),
        );
    }
  }

  Color get _bannerColor {
    switch (type) {
      case DialogType.error:
        return supportErrorColor;
      case DialogType.info:
        return supportInfoColor;
      case DialogType.warn:
        return supportWarningColor;
      case DialogType.success:
        return supportSuccessColor;
    }
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Icon(type.icon, color: Colors.white),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  void show(BuildContext context) {
    const radius = 8.0;

    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 300,
              maxWidth: double.infinity,
            ),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Paint-dipped banner
                  Container(
                    decoration: BoxDecoration(
                      color: _bannerColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(radius),
                        topRight: Radius.circular(radius),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: _buildTitle(),
                  ),
                  // Content
                  Padding(padding: const EdgeInsets.all(24), child: message),
                  // Actions
                  if (actions != null && actions!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: actions!,
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
