import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/widgets/app_bar/actions/connection_action.dart';
import 'package:tms/widgets/app_bar/leading.dart';
import 'package:tms/widgets/app_bar/actions/login_action.dart';
import 'package:tms/widgets/app_bar/actions/theme_action.dart';
import 'package:tms/widgets/app_bar/title.dart';

class TmsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GoRouterState state;

  const TmsAppBar({
    Key? key,
    required this.state,
  }) : super(key: key);

  List<Widget> _actions(BuildContext context) {
    // switch actions to submenu if the screen is small
    if (ResponsiveBreakpoints.of(context).isMobile) {
      return [
        PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(child: TmsAppBarThemeAction()),
            PopupMenuItem(child: TmsAppBarConnectionAction(state: state)),
            PopupMenuItem(child: TmsAppBarLoginAction(state: state)),
          ],
        ),
      ];
    } else {
      return [
        const TmsAppBarThemeAction(),
        TmsAppBarConnectionAction(state: state),
        TmsAppBarLoginAction(state: state),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // we have a manual checker in Leading
      leading: TmsAppBarLeading(state: this.state),
      title: TmsAppBarTitle(),
      centerTitle: true,
      // leadingWidth: 100,
      actions: _actions(context),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
