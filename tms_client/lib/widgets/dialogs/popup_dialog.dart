import 'package:flutter/material.dart';
import 'package:tms/widgets/dialogs/base_dialog.dart';

class PopupDialog extends BaseDialog {
  final String title;
  final String message;
  final DialogType type;

  PopupDialog._({required this.title, required this.message, required this.type});

  factory PopupDialog.info({required String title, required String message}) {
    return PopupDialog._(title: title, message: message, type: DialogType.info);
  }

  factory PopupDialog.success({required String title, required String message}) {
    return PopupDialog._(title: title, message: message, type: DialogType.success);
  }

  factory PopupDialog.error({required String title, required String message}) {
    return PopupDialog._(title: title, message: message, type: DialogType.error);
  }

  factory PopupDialog.warn({required String title, required String message}) {
    return PopupDialog._(title: title, message: message, type: DialogType.warn);
  }

  Widget _buildTitle() {
    IconData iconData;
    Color color;

    switch (type) {
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
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: _buildTitle(),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
