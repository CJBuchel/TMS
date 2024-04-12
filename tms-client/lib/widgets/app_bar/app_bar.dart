import 'package:flutter/material.dart';
import 'package:tms/widgets/app_bar/app_bar_login_action.dart';
import 'package:tms/widgets/app_bar/app_bar_title.dart';

class TmsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TmsAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      title: TmsAppBarTitle(),
      centerTitle: true,
      leadingWidth: 100,
      actions: [
        const TmsAppBarLoginAction(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
