import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:flutter_svg/svg.dart';

class DrawerListTile extends StatelessWidget {
  final String title, svgSrc;
  final VoidCallback press;
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppTheme.isDarkThemeNotifier,
      builder: (context, dark, child) {
        return ListTile(
          onTap: press,
          horizontalTitleGap: 0.0,
          leading: SvgPicture.asset(
            svgSrc,
            colorFilter: ColorFilter.mode(dark ? Colors.white : Colors.black, BlendMode.srcIn),
            height: 16,
          ),
          title: Text(
            title,
            style: TextStyle(color: dark ? Colors.white : Colors.black),
          ),
        );
      },
    );
  }
}
