import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/providers/theme_provider.dart';
import 'package:tms_client/router.dart';
import 'package:tms_client/theme.dart';

class TmsApp extends ConsumerWidget {
  const TmsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp.router(
      title: 'TMS',
      debugShowCheckedModeBanner: true,
      routerConfig: router,
      themeMode: themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
    );
  }
}
