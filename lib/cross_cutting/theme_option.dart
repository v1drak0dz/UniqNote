import 'package:flutter/material.dart';

class ThemeOption {
  final String translationKey;
  final Color color;

  const ThemeOption(this.translationKey, this.color);

  static double themeContrast = 0.0;
}

class ThemeFontOption {
  final String key;
  final TextTheme theme;
  final TextStyle Function({TextStyle? textStyle}) font;

  const ThemeFontOption(this.key, this.theme, this.font);
}
