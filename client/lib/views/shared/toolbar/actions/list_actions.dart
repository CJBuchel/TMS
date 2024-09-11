import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/views/shared/toolbar/actions/connection_action.dart';
import 'package:tms/views/shared/toolbar/actions/login_action.dart';
import 'package:tms/views/shared/toolbar/actions/theme_action.dart';

List<Widget> tmsToolBarActions(BuildContext context, bool displayLogicActions) {
  if (!Responsive.isMobile(context)) {
    // desktop and tablet
    if (displayLogicActions) {
      return [
        const TmsToolBarThemeAction(),
        const TmsToolBarConnectionAction(),
        const TmsToolBarLoginAction(),
      ];
    } else {
      return [
        const TmsToolBarThemeAction(),
      ];
    }
  } else {
    // mobile
    if (displayLogicActions) {
      return [
        PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          itemBuilder: (context) => [
            const PopupMenuItem(child: TmsToolBarThemeAction(listTile: true)),
            const PopupMenuItem(child: TmsToolBarConnectionAction(listTile: true)),
            const PopupMenuItem(child: TmsToolBarLoginAction(listTile: true)),
          ],
        ),
      ];
    } else {
      return [
        PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: Colors.blueGrey[800],
          itemBuilder: (context) => [
            const PopupMenuItem(child: TmsToolBarThemeAction(listTile: true)),
          ],
        )
      ];
    }
  }
}
