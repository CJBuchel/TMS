import 'package:flutter/material.dart';
import 'package:tms/views/shared/toolbar/title_bar.dart';

class TmsToolBarTitle extends StatelessWidget {
  final bool displayMenuButton;
  final VoidCallback? onMenuButtonPressed;

  const TmsToolBarTitle({
    Key? key,
    this.displayMenuButton = false,
    this.onMenuButtonPressed,
  }) : super(key: key);

  void menuButtonPressed(BuildContext context) {
    if (onMenuButtonPressed != null) {
      onMenuButtonPressed?.call();
    } else {
      Scaffold.of(context).openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // menu button
        if (displayMenuButton)
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => menuButtonPressed(context),
          ),

        // spacer
        const Expanded(child: SizedBox.shrink()),

        // title
        Center(
          child: TmsToolBarTitleBar(),
        ),

        // spacer
        const Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}
