import 'package:flutter/material.dart';
import 'package:tms_client/colors.dart';

ThemeData _buildTheme(Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;

  final colorScheme = ColorScheme.fromSeed(
    brightness: brightness,
    seedColor: primaryColor,
    primary: primaryColor,
    secondary: secondaryColor,
    error: supportErrorColor,
    // Dark: neutral base with lighter containers | Light: lightSurfaceColor shades
    surface: isDark ? neutralColor : lightSurfaceColor[50],
    surfaceContainerLowest: isDark ? surfaceColor[900] : Colors.white,
    surfaceContainerLow: isDark ? surfaceColor[800] : lightSurfaceColor[100],
    surfaceContainer: isDark ? surfaceColor[700] : lightSurfaceColor[200],
    surfaceContainerHigh: isDark ? surfaceColor[600] : lightSurfaceColor[300],
    surfaceContainerHighest: isDark ? surfaceColor : lightSurfaceColor[400],
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.white,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all<double>(0.0),
        backgroundColor: WidgetStateProperty.all<Color?>(primaryColor),

        foregroundColor: WidgetStateProperty.all<Color?>(Colors.white),
        overlayColor: WidgetStateProperty.all<Color?>(primaryColor[800]),
        enableFeedback: true,
        shape: WidgetStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shadowColor: Colors.black26,
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(16),
      ),
    ),
  );
}

ThemeData get darkTheme => _buildTheme(Brightness.dark);
ThemeData get lightTheme => _buildTheme(Brightness.light);
