import 'package:flutter/material.dart';

class ThemeHandler {
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.primary;
  }

  static Color getForegroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : Theme.of(context).colorScheme.onPrimary;
  }

  static Color getBackgroundColorSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.secondaryContainer
        : Theme.of(context).colorScheme.secondary;
  }

  static Color getForegroundColorSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.onSecondaryContainer
        : Theme.of(context).colorScheme.onSecondary;
  }
}
