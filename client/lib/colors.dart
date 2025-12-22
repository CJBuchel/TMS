import 'package:flutter/material.dart';

const _primaryColor = Color(0xFF009485);
const _secondaryColor = Color(0xFF005994);

const _supportErrorColor = Color(0xFFD92B2B);
const _supportWarningColor = Color(0xFFD9822B);
const _supportSuccessColor = Color(0xFF2BD92B);
const _supportInfoColor = Color(0xFF2B65D9);
const _neutralColor = Color(0xFF20222F);

MaterialColor _createMaterialColor(Color color) {
  final strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
  final swatch = <int, Color>{};
  final r = color.r, g = color.g, b = color.b;

  for (final strength in strengths) {
    final ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.from(
      alpha: 1.0,
      red: r + ((ds < 0 ? r : (1.0 - r)) * ds),
      green: g + ((ds < 0 ? g : (1.0 - g)) * ds),
      blue: b + ((ds < 0 ? b : (1.0 - b)) * ds),
    );
  }
  return MaterialColor(color.toARGB32(), swatch);
}

final primaryColor = _createMaterialColor(_primaryColor);
final secondaryColor = _createMaterialColor(_secondaryColor);
final supportErrorColor = _createMaterialColor(_supportErrorColor);
final supportWarningColor = _createMaterialColor(_supportWarningColor);
final supportSuccessColor = _createMaterialColor(_supportSuccessColor);
final supportInfoColor = _createMaterialColor(_supportInfoColor);
final neutralColor = _createMaterialColor(_neutralColor);

// Vibrant colors palette - avoiding cyan/teal/blue to prevent clash with primary/secondary
const _vibrantColorPalette = [
  Color(0xFFE74C3C), // Red
  Color(0xFF9B59B6), // Purple
  Color(0xFFF39C12), // Orange
  Color(0xFF2ECC71), // Green
  Color(0xFFE91E63), // Pink/Magenta
  Color(0xFFD35400), // Dark Orange
  Color(0xFFF1C40F), // Yellow
  Color(0xFF16A085), // Dark Teal (warmer, less blue)
  Color(0xFFBDC3C7), // Silver
];

/// Get a vibrant color by index. Wraps around infinitely.
/// Avoids cyan/teal/blue hues that would clash with primary/secondary colors.
Color vibrantColors(int index) {
  return _vibrantColorPalette[index % _vibrantColorPalette.length];
}
