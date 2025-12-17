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
