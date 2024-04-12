import 'package:flutter/material.dart';
import 'package:tms/app.dart';

class TmsAppBarThemeAction extends StatelessWidget {
  const TmsAppBarThemeAction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        TMSApp.of(context).changeTheme(
          TMSApp.of(context).themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
        );
      },
      icon: Icon(
        TMSApp.of(context).themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
      ),
    );
  }
}
