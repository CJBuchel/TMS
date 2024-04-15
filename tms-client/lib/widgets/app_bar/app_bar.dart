import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tms/widgets/app_bar/app_bar_connection.dart';
import 'package:tms/widgets/app_bar/app_bar_leading.dart';
import 'package:tms/widgets/app_bar/app_bar_login_action.dart';
import 'package:tms/widgets/app_bar/app_bar_theme_action.dart';
import 'package:tms/widgets/app_bar/app_bar_title.dart';

class TmsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GoRouterState state;

  const TmsAppBar({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: TmsAppBarLeading(state: this.state),
      title: TmsAppBarTitle(),
      centerTitle: true,
      leadingWidth: 100,
      actions: [
        const TmsAppBarThemeAction(),
        TmsAppBarConnectionAction(state: state),
        TmsAppBarLoginAction(state: state),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
