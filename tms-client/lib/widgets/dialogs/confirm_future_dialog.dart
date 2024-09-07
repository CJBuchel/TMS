import 'package:flutter/material.dart';
import 'package:tms/widgets/dialogs/base_dialog.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:go_router/go_router.dart';
import 'package:tms/widgets/dialogs/snackbar_dialog.dart';

class ConfirmFutureDialog extends BaseDialog {
  final ConfirmDialogStyle style;
  final Future<void> Function()? onConfirmFuture;
  final Future<int> Function()? onStatusConfirmFuture;
  final Function(int? status)? onFinish;

  bool _isLoading = false;

  ConfirmFutureDialog({
    required this.style,
    this.onConfirmFuture,
    this.onStatusConfirmFuture,
    this.onFinish,
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

  List<Widget> _buildActions(BuildContext context, StateSetter setState) {
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
          context.pop();
        },
        child: const Text("Cancel"),
      ),
      TextButton(
        onPressed: () async {
          setState(() {
            _isLoading = true;
          });

          int? status;

          if (onStatusConfirmFuture != null) {
            status = await onStatusConfirmFuture!.call();
            SnackBarDialog.fromStatus(message: style.title, status: status).show(context);
          } else {
            await onConfirmFuture?.call();
          }

          context.pop();
          onFinish?.call(status);
        },
        child: Text("Confirm", style: TextStyle(color: color)),
      ),
    ];
  }

  Widget _content() {
    if (_isLoading) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 10),
          const Text("Loading..."),
        ],
      );
    } else {
      return style.message;
    }
  }

  List<Widget> _actions(BuildContext context, StateSetter setState) {
    if (_isLoading) {
      return [];
    } else {
      return _buildActions(context, setState);
    }
  }

  @override
  void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: _buildTitle(),
              content: _content(),
              actions: _actions(context, setState),
            );
          },
        );
      },
    );
  }
}
