import 'package:flutter/material.dart';
import 'package:tms/constants.dart';

class TmsToolBarThemeAction extends StatelessWidget {
  final bool? listTile;
  const TmsToolBarThemeAction({
    Key? key,
    this.listTile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppTheme.isDarkThemeNotifier,
      builder: (context, isDarkTheme, _) {
        if (listTile ?? false) {
          return ListTile(
            leading: Icon(
              isDarkTheme ? Icons.light_mode : Icons.brightness_3_sharp,
              color: isDarkTheme ? Colors.white : Colors.black,
            ),
            title: const Text("Theme"),
            onTap: () {
              Navigator.pop(context);
              AppTheme.setDarkTheme = !isDarkTheme;
            },
          );
        } else {
          return IconButton(
            icon: Icon(
              isDarkTheme ? Icons.light_mode : Icons.brightness_3_sharp,
              color: Colors.white,
            ),
            onPressed: () {
              AppTheme.setDarkTheme = !isDarkTheme;
            },
          );
        }
      },
    );
  }
}
