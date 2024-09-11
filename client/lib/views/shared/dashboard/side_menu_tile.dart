import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:flutter_svg/svg.dart';

class DrawerListTile extends StatelessWidget {
  final String title;
  final String? svgSrc;
  final IconData? icon;

  final VoidCallback press;
  const DrawerListTile({
    Key? key,
    this.svgSrc,
    this.icon,
    required this.title,
    required this.press,
  }) : super(key: key);

  Widget getIcon(bool dark) {
    if (svgSrc != null) {
      return SvgPicture.asset(
        svgSrc!,
        colorFilter: ColorFilter.mode(dark ? Colors.white : Colors.black, BlendMode.srcIn),
        height: 16,
      );
    } else if (icon != null) {
      return Icon(icon, color: dark ? Colors.white : Colors.black, size: 16);
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppTheme.isDarkThemeNotifier,
      builder: (context, dark, child) {
        return ListTile(
          onTap: press,
          horizontalTitleGap: 0.0,
          leading: getIcon(dark),
          title: Text(
            title,
            style: TextStyle(color: dark ? Colors.white : Colors.black),
          ),
        );
      },
    );
  }
}
