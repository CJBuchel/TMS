import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract class BaseDialog extends StatelessWidget {
  final Widget title;
  final Widget content;

  BaseDialog({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: content,
      actions: [
        TextButton(
          onPressed: () => context.canPop() ? context.pop() : null,
          child: const Text('OK'),
        ),
      ],
    );
  }
}
