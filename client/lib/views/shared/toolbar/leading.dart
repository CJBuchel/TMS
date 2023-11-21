import 'package:flutter/material.dart';

class TmsToolBarLeading extends StatelessWidget {
  final VoidCallback? onBackButtonPressed;

  const TmsToolBarLeading({
    Key? key,
    this.onBackButtonPressed,
  }) : super(key: key);

  void _pop(BuildContext context) {
    if (Navigator.canPop(context) && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  build(BuildContext context) {
    if (Navigator.canPop(context) && Navigator.of(context).canPop()) {
      return IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBackButtonPressed ?? () => _pop(context));
    } else {
      return const SizedBox.shrink();
    }
  }
}
