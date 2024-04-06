import 'package:flutter/material.dart';
import 'package:tms/widgets/app_bar/app_bar_title.dart';

class TmsAppBar extends StatefulWidget implements PreferredSizeWidget {
  const TmsAppBar({Key? key}) : super(key: key);

  @override
  State<TmsAppBar> createState() => _TmsAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class _TmsAppBarState extends State<TmsAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      title: TmsAppBarTitle(),
      centerTitle: true,
      leadingWidth: 100,
    );
  }
}
