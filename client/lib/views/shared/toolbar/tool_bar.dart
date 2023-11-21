import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/views/shared/toolbar/actions/list_actions.dart';
import 'package:tms/views/shared/toolbar/leading.dart';
import 'package:tms/views/shared/toolbar/title.dart';

class TmsToolBar extends StatelessWidget implements PreferredSizeWidget {
  final bool displayLogicActions;
  final bool displayMenuButton;
  final VoidCallback? onBackButtonPressed;
  final VoidCallback? onMenuButtonPressed;

  @override
  Size get preferredSize => const Size.fromHeight(50);

  const TmsToolBar({
    Key? key,
    this.displayLogicActions = true,
    this.displayMenuButton = false,
    this.onBackButtonPressed,
    this.onMenuButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double scaledFontSize = 20; // medium

    if (Responsive.isDesktop(context)) {
      scaledFontSize = 25;
    } else if (Responsive.isTablet(context)) {
      scaledFontSize = 20;
    } else if (Responsive.isMobile(context)) {
      scaledFontSize = 15;
    }

    return AppBar(
      backgroundColor: Colors.blueGrey[800],
      iconTheme: IconThemeData(size: scaledFontSize, color: Colors.white),

      // leading button (back button if possible)
      leading: const TmsToolBarLeading(),

      // main title
      title: TmsToolBarTitle(
        displayMenuButton: displayMenuButton,
        onMenuButtonPressed: onMenuButtonPressed,
      ),

      // get the actions
      actions: tmsToolBarActions(context, displayLogicActions),
    );
  }
}
