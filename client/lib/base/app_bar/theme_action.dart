import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/providers/theme_provider.dart';

class BaseAppBarThemeAction extends ConsumerWidget {
  const BaseAppBarThemeAction({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeModeProvider);

    return IconButton(
      onPressed: () {
        ref.read(appThemeModeProvider.notifier).toggleTheme();
      },
      icon: Icon(theme == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
    );
  }
}
