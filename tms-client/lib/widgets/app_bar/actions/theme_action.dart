import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/app.dart';
import 'package:tms/providers/local_storage_provider.dart';

class TmsAppBarThemeAction extends StatelessWidget {
  const TmsAppBarThemeAction({Key? key}) : super(key: key);
  // theme provider

  // filter theme mode to only light or dark mode. If system mode is selected, then check platform theme
  ThemeMode getTheme(BuildContext context, ThemeMode initial) {
    if (initial != ThemeMode.system) {
      return initial;
    } else {
      final brightness = MediaQuery.of(context).platformBrightness;
      return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<TmsLocalStorageProvider, ThemeMode>(
      selector: (_, localStorageProvider) => localStorageProvider.themeMode,
      builder: (_, themeMode, __) => IconButton(
        onPressed: () {
          TMSApp.of(context).changeTheme(
            getTheme(context, themeMode) == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
          );
        },
        icon: Icon(
          getTheme(context, themeMode) == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
        ),
      ),
    );
  }
}
