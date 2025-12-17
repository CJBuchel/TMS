import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tms_client/helpers/local_storage.dart';

part 'theme_provider.g.dart';

ThemeMode get _defaultThemeMode => ThemeMode.system;

@riverpod
class AppThemeMode extends _$AppThemeMode {
  final String _key = 'theme_mode';

  void toggleTheme() =>
      setThemeMode(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);

  void setThemeMode(ThemeMode mode) {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    localStorage.setString(_key, value);
    state = mode;
  }

  @override
  ThemeMode build() {
    return switch (localStorage.getString(_key)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => _defaultThemeMode,
    };
  }
}
