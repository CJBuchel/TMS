import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tms_client/utils/grpc_result.dart';
import 'package:tms_client/widgets/dialogs/base_dialog.dart';
import 'package:tms_client/widgets/dialogs/popup_dialog.dart';

class ConfirmDialog extends BaseDialog {
  final PopupDialog _popupDialog;

  ConfirmDialog({
    required String title,
    required Widget message,
    required DialogType type,
    VoidCallback? onConfirm,
    Future<void> Function()? onConfirmAsync,
    Future<GrpcResult<dynamic>> Function()? onConfirmAsyncGrpc,
    VoidCallback? onCancel,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool showResultDialog = false,
    Widget? successMessage,
  }) : _popupDialog = PopupDialog(
         title: title,
         message: message,
         type: type,
         actions: _buildActions(
           onConfirm: onConfirm,
           onConfirmAsync: onConfirmAsync,
           onConfirmAsyncGrpc: onConfirmAsyncGrpc,
           onCancel: onCancel,
           confirmText: confirmText,
           cancelText: cancelText,
           showResultDialog: showResultDialog,
           successMessage: successMessage,
         ),
       );

  @override
  void show(BuildContext context) {
    _popupDialog.show(context);
  }

  factory ConfirmDialog.info({
    required String title,
    required Widget message,
    VoidCallback? onConfirm,
    Future<void> Function()? onConfirmAsync,
    Future<GrpcResult<dynamic>> Function()? onConfirmAsyncGrpc,
    VoidCallback? onCancel,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool showResultDialog = false,
    Widget? successMessage,
  }) {
    return ConfirmDialog(
      title: title,
      message: message,
      type: DialogType.info,
      onConfirm: onConfirm,
      onConfirmAsync: onConfirmAsync,
      onConfirmAsyncGrpc: onConfirmAsyncGrpc,
      onCancel: onCancel,
      confirmText: confirmText,
      cancelText: cancelText,
      showResultDialog: showResultDialog,
      successMessage: successMessage,
    );
  }

  factory ConfirmDialog.warn({
    required String title,
    required Widget message,
    VoidCallback? onConfirm,
    Future<void> Function()? onConfirmAsync,
    Future<GrpcResult<dynamic>> Function()? onConfirmAsyncGrpc,
    VoidCallback? onCancel,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool showResultDialog = false,
    Widget? successMessage,
  }) {
    return ConfirmDialog(
      title: title,
      message: message,
      type: DialogType.warn,
      onConfirm: onConfirm,
      onConfirmAsync: onConfirmAsync,
      onConfirmAsyncGrpc: onConfirmAsyncGrpc,
      onCancel: onCancel,
      confirmText: confirmText,
      cancelText: cancelText,
      showResultDialog: showResultDialog,
      successMessage: successMessage,
    );
  }

  factory ConfirmDialog.error({
    required String title,
    required Widget message,
    VoidCallback? onConfirm,
    Future<void> Function()? onConfirmAsync,
    Future<GrpcResult<dynamic>> Function()? onConfirmAsyncGrpc,
    VoidCallback? onCancel,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool showResultDialog = false,
    Widget? successMessage,
  }) {
    return ConfirmDialog(
      title: title,
      message: message,
      type: DialogType.error,
      onConfirm: onConfirm,
      onConfirmAsync: onConfirmAsync,
      onConfirmAsyncGrpc: onConfirmAsyncGrpc,
      onCancel: onCancel,
      confirmText: confirmText,
      cancelText: cancelText,
      showResultDialog: showResultDialog,
      successMessage: successMessage,
    );
  }

  static List<Widget> _buildActions({
    VoidCallback? onConfirm,
    Future<void> Function()? onConfirmAsync,
    Future<GrpcResult<dynamic>> Function()? onConfirmAsyncGrpc,
    VoidCallback? onCancel,
    required String confirmText,
    required String cancelText,
    required bool showResultDialog,
    Widget? successMessage,
  }) {
    assert(
      onConfirm != null || onConfirmAsync != null || onConfirmAsyncGrpc != null,
      'Either onConfirm, onConfirmAsync, or onConfirmAsyncGrpc must be provided',
    );
    assert(
      (onConfirm != null ? 1 : 0) +
              (onConfirmAsync != null ? 1 : 0) +
              (onConfirmAsyncGrpc != null ? 1 : 0) ==
          1,
      'Only one of onConfirm, onConfirmAsync, or onConfirmAsyncGrpc can be provided',
    );

    return [
      Builder(
        builder: (context) => TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
          child: Text(cancelText),
        ),
      ),
      const SizedBox(width: 8),
      if (onConfirm != null)
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: Text(confirmText),
          ),
        )
      else if (onConfirmAsync != null)
        _AsyncConfirmButton(
          confirmText: confirmText,
          onConfirmAsync: onConfirmAsync,
          showResultDialog: showResultDialog,
          successMessage: successMessage,
        )
      else if (onConfirmAsyncGrpc != null)
        _AsyncGrpcConfirmButton(
          confirmText: confirmText,
          onConfirmAsyncGrpc: onConfirmAsyncGrpc,
          showResultDialog: showResultDialog,
          successMessage: successMessage,
        ),
    ];
  }
}

class _AsyncConfirmButton extends HookWidget {
  final String confirmText;
  final Future<void> Function() onConfirmAsync;
  final bool showResultDialog;
  final Widget? successMessage;

  const _AsyncConfirmButton({
    required this.confirmText,
    required this.onConfirmAsync,
    required this.showResultDialog,
    this.successMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);

    Future<void> handleConfirm() async {
      if (isLoading.value) return;

      isLoading.value = true;

      try {
        await onConfirmAsync();
        if (context.mounted) {
          Navigator.of(context).pop();

          if (showResultDialog) {
            PopupDialog.success(
              title: 'Success',
              message:
                  successMessage ??
                  const Text('Operation completed successfully'),
            ).show(context);
          }
        }
      } catch (e) {
        if (context.mounted) {
          if (showResultDialog) {
            PopupDialog.error(
              title: 'Error',
              message: Text('Operation failed: $e'),
            ).show(context);
          }
        }
      } finally {
        isLoading.value = false;
      }
    }

    return ElevatedButton(
      onPressed: isLoading.value ? null : handleConfirm,
      child: isLoading.value
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(confirmText),
    );
  }
}

class _AsyncGrpcConfirmButton extends HookWidget {
  final String confirmText;
  final Future<GrpcResult<dynamic>> Function() onConfirmAsyncGrpc;
  final bool showResultDialog;
  final Widget? successMessage;

  const _AsyncGrpcConfirmButton({
    required this.confirmText,
    required this.onConfirmAsyncGrpc,
    required this.showResultDialog,
    this.successMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);

    Future<void> handleConfirm() async {
      if (isLoading.value) return;

      isLoading.value = true;

      try {
        final result = await onConfirmAsyncGrpc();

        if (context.mounted) {
          Navigator.of(context).pop();

          if (showResultDialog) {
            PopupDialog.fromGrpcStatus(
              result: result,
              successMessage: successMessage,
            ).show(context);
          }
        }
      } catch (e) {
        if (context.mounted) {
          if (showResultDialog) {
            PopupDialog.error(
              title: 'Error',
              message: Text('Unexpected error: $e'),
            ).show(context);
          }
        }
      } finally {
        isLoading.value = false;
      }
    }

    return ElevatedButton(
      onPressed: isLoading.value ? null : handleConfirm,
      child: isLoading.value
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(confirmText),
    );
  }
}
