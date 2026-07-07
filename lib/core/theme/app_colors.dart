import 'package:flutter/material.dart';

/// Central color palette for the app.
///
/// Moved here from `lib/model/AppColors.dart` as part of the clean-architecture
/// refactor. The legacy file is kept untouched for now so existing imports keep
/// compiling; new code should import this file instead.
class AppColors {
  static Color? mainColor = Colors.blue[600];
  static Color? secondaryColor = Colors.grey;
  static Color? white = Colors.white;

  // Main colors of effects
  static Color echo = const Color.fromRGBO(141, 131, 8, 0.9294117647058824);
  static Color delay = const Color.fromRGBO(255, 60, 0, 0.9);
  static Color distortion = const Color.fromRGBO(41, 17, 169, 0.9);
  static Color fuzz = const Color.fromRGBO(56, 7, 110, 0.96);
  static Color overdrive = const Color.fromRGBO(2, 95, 3, 0.8);
  static Color reverb = const Color.fromRGBO(229, 27, 27, 0.93);
}
