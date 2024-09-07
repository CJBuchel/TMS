import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tms/widgets/dialogs/base_dialog.dart';

class ConfirmDialogStyle {
  final String title;
  final Widget message;
  final DialogType type;

  ConfirmDialogStyle._({required this.title, required this.message, required this.type});

  factory ConfirmDialogStyle.info({required String title, required Widget message}) {
    return ConfirmDialogStyle._(title: title, message: message, type: DialogType.info);
  }

  factory ConfirmDialogStyle.success({required String title, required Widget message}) {
    return ConfirmDialogStyle._(title: title, message: message, type: DialogType.success);
  }

  factory ConfirmDialogStyle.error({required String title, required Widget message}) {
    return ConfirmDialogStyle._(title: title, message: message, type: DialogType.error);
  }

  factory ConfirmDialogStyle.warn({required String title, required Widget message}) {
    return ConfirmDialogStyle._(title: title, message: message, type: DialogType.warn);
  }
}

class ConfirmDialog extends BaseDialog {
  final ConfirmDialogStyle style;
  final Function? onConfirm;
  final Function? onCancel;

  ConfirmDialog({
    required this.style,
    this.onConfirm,
    this.onCancel,
  });

  Widget _buildTitle() {
    IconData iconData;
    Color color;

    switch (style.type) {
      case DialogType.error:
        iconData = Icons.error;
        color = Colors.red;
        break;
      case DialogType.info:
        iconData = Icons.info;
        color = Colors.blue;
        break;
      case DialogType.warn:
        iconData = Icons.warning;
        color = Colors.orange;
        break;
      case DialogType.success:
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
    }

    return Row(
      children: [
        Icon(iconData, color: color),
        const SizedBox(width: 8),
        Text(
          style.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    Color color;

    switch (style.type) {
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

    return [
      TextButton(
        onPressed: () {
          onCancel?.call();
          context.pop();
        },
        child: const Text("Cancel"),
      ),
      TextButton(
        onPressed: () {
          onConfirm?.call();
          context.pop();
        },
        child: Text(
          "Confirm",
          style: TextStyle(color: color),
        ),
      ),
    ];
  }

  @override
  void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: _buildTitle(),
          content: style.message,
          actions: _buildActions(context),
        );
      },
    );
  }
}
