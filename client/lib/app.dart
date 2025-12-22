import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/providers/theme_provider.dart';
import 'package:tms_client/providers/token_validator_provider.dart';
import 'package:tms_client/router/router.dart';
import 'package:tms_client/theme.dart';

class TmsApp extends ConsumerWidget {
  const TmsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);

    // Initialize token validator to monitor app lifecycle
    ref.watch(tokenValidatorProvider);

    return MaterialApp.router(
      title: 'TMS',
      debugShowCheckedModeBanner: true,
      routerConfig: ref.watch(routerProvider),
      themeMode: themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
    );
  }
}
